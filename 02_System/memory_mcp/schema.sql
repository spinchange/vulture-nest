CREATE TABLE IF NOT EXISTS session_memories (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id  TEXT    NOT NULL,
    key         TEXT    NOT NULL,
    content     TEXT    NOT NULL,
    tags        TEXT    NOT NULL DEFAULT '[]',
    created_at  TEXT    NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ', 'now')),
    UNIQUE(session_id, key)
);

CREATE INDEX IF NOT EXISTS idx_session_memories_session ON session_memories(session_id);
CREATE INDEX IF NOT EXISTS idx_session_memories_tags ON session_memories(tags);

CREATE TABLE IF NOT EXISTS vault_memories (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    key         TEXT    NOT NULL UNIQUE,
    content     TEXT    NOT NULL,
    tags        TEXT    NOT NULL DEFAULT '[]',
    embedding   BLOB,
    created_at  TEXT    NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ', 'now')),
    updated_at  TEXT    NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ', 'now'))
);

CREATE INDEX IF NOT EXISTS idx_vault_memories_tags ON vault_memories(tags);

CREATE VIRTUAL TABLE IF NOT EXISTS session_fts USING fts5(
    key, content, tags,
    content=session_memories, content_rowid=id
);

CREATE VIRTUAL TABLE IF NOT EXISTS vault_fts USING fts5(
    key, content, tags,
    content=vault_memories, content_rowid=id
);

CREATE TRIGGER IF NOT EXISTS session_ai AFTER INSERT ON session_memories BEGIN
    INSERT INTO session_fts(rowid, key, content, tags) VALUES (new.id, new.key, new.content, new.tags);
END;

CREATE TRIGGER IF NOT EXISTS session_ad AFTER DELETE ON session_memories BEGIN
    INSERT INTO session_fts(session_fts, rowid, key, content, tags) VALUES('delete', old.id, old.key, old.content, old.tags);
END;

CREATE TRIGGER IF NOT EXISTS session_au AFTER UPDATE ON session_memories BEGIN
    INSERT INTO session_fts(session_fts, rowid, key, content, tags) VALUES('delete', old.id, old.key, old.content, old.tags);
    INSERT INTO session_fts(rowid, key, content, tags) VALUES (new.id, new.key, new.content, new.tags);
END;

CREATE TRIGGER IF NOT EXISTS vault_ai AFTER INSERT ON vault_memories BEGIN
    INSERT INTO vault_fts(rowid, key, content, tags) VALUES (new.id, new.key, new.content, new.tags);
END;

CREATE TRIGGER IF NOT EXISTS vault_ad AFTER DELETE ON vault_memories BEGIN
    INSERT INTO vault_fts(vault_fts, rowid, key, content, tags) VALUES('delete', old.id, old.key, old.content, old.tags);
END;

CREATE TRIGGER IF NOT EXISTS vault_au AFTER UPDATE ON vault_memories BEGIN
    INSERT INTO vault_fts(vault_fts, rowid, key, content, tags) VALUES('delete', old.id, old.key, old.content, old.tags);
    INSERT INTO vault_fts(rowid, key, content, tags) VALUES (new.id, new.key, new.content, new.tags);
END;
