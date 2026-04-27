import importlib.util
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).parent / "memory_mcp"))

from server import commit_memory, init_db, prune_memory, search_memories


def test_memory_mcp_smoke():
    db_path = Path(__file__).parent / "memory_mcp" / "_test_memory.db"
    if db_path.exists():
        db_path.unlink()
    try:
        db = init_db(db_path)
        committed = commit_memory(db, scope="vault", key="test", content="hello world", tags=["test"])
        assert committed == {"committed": True, "key": "test", "scope": "vault"}

        searched = search_memories(db, query="hello", scope="vault")
        assert any(result["key"] == "test" for result in searched["results"])

        pruned = prune_memory(db, scope="vault", key="test")
        assert pruned["pruned_count"] == 1

        try:
            prune_memory(db, scope="vault")
        except ValueError as exc:
            assert "Bulk vault prune requires at least one filter." in str(exc)
        else:
            raise AssertionError("Expected bulk vault prune guard to reject unfiltered prune")

        db.close()
    finally:
        if db_path.exists():
            db_path.unlink()


def test_server_module_loads_without_mcp_sdk():
    assert importlib.util.find_spec("server") is not None
