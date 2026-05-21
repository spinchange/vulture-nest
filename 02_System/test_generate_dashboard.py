from pathlib import Path
import re


SCRIPT_PATH = Path(__file__).parent / "generate-dashboard.ps1"


def test_generate_dashboard_git_stats_are_repo_anchored():
    script = SCRIPT_PATH.read_text(encoding="utf-8")

    match = re.search(
        r"function Get-GitStats \{\s*(.*?)\n\s*\}\n\n\s*function Get-RecentLogActions",
        script,
        re.DOTALL,
    )
    assert match, "Get-GitStats function block was not found in generate-dashboard.ps1"

    block = match.group(1)
    assert "git -C $VaultRoot rev-list" in block
    assert "git -C $VaultRoot rev-parse" in block
    assert "git -C $VaultRoot log" in block
