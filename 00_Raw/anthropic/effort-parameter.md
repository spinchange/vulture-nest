<!--
source_url: https://platform.claude.com/docs/en/build-with-claude/effort
requested_url: https://platform.claude.com/docs/en/build-with-claude/effort
fetch_date: 2026-05-02T01:27:44.571Z
crawl_job_id: 019debff-458b-7304-90fe-9ab6550b4064
source_page_id: ec8b6aeb-e233-487d-a13f-547d8beb2a4f
chunk_ids: cf5f7138-5951-47ee-9bac-3ea56b9fa4ae, c35c7c7f-08d4-4b49-8f46-8ce7cdec9a4e, fc2e4af3-4ee6-47de-8ef1-48a1deddd001, d235196b-29b0-44eb-812b-490600c8d625, 6f1954ee-c97d-4d5a-a616-0348bfd9dd2c, 43e26f98-eb1c-4349-a086-8b1f7a3a9443, e90e81f5-947c-4002-bc3e-2b893f224b01, b3858db0-2ae6-4df6-8233-84d831aa4c2a, 9fc0ea5f-96a9-4fbf-938d-0371d98d53af
-->

# Effort - Claude API Docs
Model capabilities

Effort

Copy page

This feature is eligible for [Zero Data Retention (ZDR)](https://platform.claude.com/docs/en/build-with-claude/api-and-data-retention). When your organization has a ZDR arrangement, data sent through this feature is not stored after the API response is returned.

The effort parameter allows you to control how eager Claude is about spending tokens when responding to requests. This gives you the ability to trade off between response thoroughness and token efficiency, all with a single model. The effort parameter is generally available on all supported models with no beta header required.

The effort parameter is supported by [Claude Mythos Preview](https://anthropic.com/glasswing), Claude Opus 4.7, Claude Opus 4.6, Claude Sonnet 4.6, and Claude Opus 4.5.

For Claude Opus 4.6 and Sonnet 4.6, effort replaces `budget_tokens` as the recommended way to control thinking depth. Combine effort with [adaptive thinking](https://platform.claude.com/docs/en/build-with-claude/adaptive-thinking) (`thinking: {type: "adaptive"}`) for the best experience. While `budget_tokens` is still accepted on Opus 4.6 and Sonnet 4.6, it is deprecated and will be removed in a future model release. At `high` (default) and `max` effort, Claude will almost always think. At lower effort levels, it may skip thinking for simpler problems.

## How effort works

By default, Claude uses high effort, spending as many tokens as needed for excellent results. You can raise the effort level to `max` for the absolute highest capability, or lower it to be more conservative with token usage, optimizing for speed and cost while accepting some reduction in capability.

Setting `effort` to `"high"` produces exactly the same behavior as omitting the `effort` parameter entirely.

The effort parameter affects **all tokens** in the response, including:

- Text responses and explanations
- Tool calls and function arguments
- Extended thinking (when enabled)

This approach has two major advantages:

1. It doesn't require thinking to be enabled in order to use it.
2. It can affect all token spend including tool calls. For example, lower effort would mean Claude makes fewer tool calls. This gives a much greater degree of control over efficiency.

### Effort levels

| Level | Description | Typical use case |
| --- | --- | --- |
| `max` | Absolute maximum capability with no constraints on token spending. Available on Claude Mythos Preview, Claude Opus 4.7, Claude Opus 4.6, and Claude Sonnet 4.6. | Tasks requiring the deepest possible reasoning and most thorough analysis |
| `xhigh` | Extended capability for long-horizon work. Available on Claude Opus 4.7. | Long-running agentic and coding tasks (over 30 minutes) with token budgets in the millions |
| `high` | High capability. Equivalent to not setting the parameter. | Complex reasoning, difficult coding problems, agentic tasks |
| `medium` | Balanced approach with moderate token savings. | Agentic tasks that require a balance of speed, cost, and performance |
| `low` | Most efficient. Significant token savings with some capability reduction. | Simpler tasks that need the best speed and lowest costs, such as subagents |

Effort is a behavioral signal, not a strict token budget. At lower effort levels, Claude will still think on sufficiently difficult problems, but it will think less than it would at higher effort levels for the same problem.

### Recommended effort levels for Sonnet 4.6

Sonnet 4.6 defaults to `high` effort. Explicitly set effort when using Sonnet 4.6 to avoid unexpected latency:

- **Medium effort** (recommended default): Best balance of speed, cost, and performance for most applications. Suitable for agentic coding, tool-heavy workflows, and code generation.
- **Low effort:** For high-volume or latency-sensitive workloads. Suitable for chat and non-coding use cases where faster turnaround is prioritized.
- **High effort:** For tasks requiring maximum intelligence from Sonnet 4.6.
- **Max effort:** For tasks requiring the absolute highest capability with no constraints on token spending.

### Recommended effort levels for Claude Opus 4.7

**Start with `xhigh` for coding and agentic use cases**, and use `high` as the minimum for most intelligence-sensitive workloads. Step down to `medium` for cost-sensitive workloads, or up to `max` only when your evals show measurable headroom at `xhigh`.

The API default is `high`. To use `xhigh`, set `effort` explicitly; the value you pass overrides the default.

| Effort | Guidance for Claude Opus 4.7 |
| --- | --- |
| `low` | Efficient, but best for short, scoped tasks. Pair `low` with explicit checklists if your task has multiple sections. |
| `medium` | The drop-in for the average workflow where you want good results while reducing costs. |
| `high` | Advanced use cases that still need a balance of intelligence and token consumption. This is often the sweet spot balancing quality and token efficiency. |
| `xhigh` | The recommended starting point for coding and agentic work, and for exploratory tasks such as repeated tool calling, detailed web search, and knowledge-base search. Expect meaningfully higher token usage than `high`. |
| `max` | Reserve for genuinely frontier problems. On most workloads `max` adds significant cost for relatively small quality gains, and on some structured-output or less intelligence-sensitive tasks it can lead to overthinking. |

Claude Opus 4.7 also respects effort levels more strictly than Claude Opus 4.6, especially at `low` and `medium`. At lower effort levels, the model scopes its work to what was asked rather than going above and beyond. If you observe shallow reasoning on complex problems with Claude Opus 4.7, raise effort rather than prompting around it. If you must keep effort low for latency, add targeted guidance like "This task involves multi-step reasoning. Think carefully before responding."

When running Claude Opus 4.7 at `xhigh` or `max` effort, set a large `max_tokens` so the model has room to think and act across subagents and tool calls. Starting at 64k tokens and tuning from there is a reasonable default.

## Basic usage

cURLCLIPythonTypeScriptC#GoJavaPHPRuby

```
client = anthropic.Anthropic()

response = client.messages.create(
    model="claude-opus-4-7",
    max_tokens=4096,
    messages=[\
        {\
            "role": "user",\
            "content": "Analyze the trade-offs between microservices and monolithic architectures",\
        }\
    ],
    output_config={"effort": "medium"},
)

print(response.content[0].text)
```

## When to adjust the effort parameter

- Use **max effort** when you need the absolute highest capability with no constraints: the most thorough reasoning and deepest analysis. Available on Claude Mythos Preview, Claude Opus 4.7, Claude Opus 4.6, and Claude Sonnet 4.6.
- Use **xhigh effort** for advanced coding and complex agentic work requiring extended exploration, such as repeated tool calling and detailed search. Available on Claude Opus 4.7.
- Use **high effort** (the default) when you need Claude's best work: complex reasoning, nuanced analysis, difficult coding problems, or any task where quality is the top priority.
- Use **medium effort** as a balanced option when you want solid performance without the full token expenditure of high effort.
- Use **low effort** when you're optimizing for speed (because Claude answers with fewer tokens) or cost. For example, simple classification tasks, quick lookups, or high-volume use cases where marginal quality improvements don't justify additional latency or spend.

## Effort with tool use

When using tools, the effort parameter affects both the explanations around tool calls and the tool calls themselves. Lower effort levels tend to:

- Combine multiple operations into fewer tool calls
- Make fewer tool calls
- Proceed directly to action without preamble
- Use terse confirmation messages after completion

Higher effort levels may:

- Make more tool calls
- Explain the plan before taking action
- Provide detailed summaries of changes
- Include more comprehensive code comments

## Effort with extended thinking

The effort parameter works alongside extended thinking. Its behavior depends on the model:

- **Claude Mythos Preview** uses [adaptive thinking](https://platform.claude.com/docs/en/build-with-claude/adaptive-thinking) by default (no `thinking` configuration required). `thinking: {type: "disabled"}` is rejected. Effort controls thinking depth the same way as on Opus 4.7 and Opus 4.6.
- **Claude Opus 4.7** uses [adaptive thinking](https://platform.claude.com/docs/en/build-with-claude/adaptive-thinking) (`thinking: {type: "adaptive"}`), where effort is the recommended control for thinking depth. Manual extended thinking (`thinking: {type: "enabled", budget_tokens: N}`) is no longer supported on Opus 4.7; use adaptive thinking with effort instead. At `high`, `xhigh`, and `max` effort, Claude almost always thinks deeply. At lower levels, it may skip thinking for simpler problems.
- **Claude Opus 4.6** uses [adaptive thinking](https://platform.claude.com/docs/en/build-with-claude/adaptive-thinking) (`thinking: {type: "adaptive"}`), where effort is the recommended control for thinking depth. While `budget_tokens` is still accepted on Opus 4.6, it is deprecated and will be removed in a future release. At `high` and `max` effort, Claude almost always thinks deeply. At lower levels, it may skip thinking for simpler problems.
- **Claude Sonnet 4.6** uses [adaptive thinking](https://platform.claude.com/docs/en/build-with-claude/adaptive-thinking) (where effort controls thinking depth). Manual thinking with [interleaved mode](https://platform.claude.com/docs/en/build-with-claude/extended-thinking#interleaved-thinking) (`thinking: {type: "enabled", budget_tokens: N}`) is still functional but deprecated.
- **Claude Opus 4.5 and other Claude 4 models** use manual thinking (`thinking: {type: "enabled", budget_tokens: N}`), where effort works alongside the thinking token budget. Set the effort level for your task, then set the thinking token budget based on task complexity.

The effort parameter can be used with or without extended thinking enabled. When used without thinking, it still controls overall token spend for text responses and tool calls.

## Best practices

1. **Set effort explicitly:** The API defaults to `high`, but the right starting point depends on your model and workload.
2. **Use low for speed-sensitive or simple tasks:** When latency matters or tasks are straightforward, low effort can significantly reduce response times and costs.
3. **Test your use case:** The impact of effort levels varies by task type. Evaluate performance on your specific use cases before deploying.
4. **Consider dynamic effort:** Adjust effort based on task complexity. Simple queries may warrant low effort while agentic coding and complex reasoning benefit from high effort.

Was this page helpful?

Ask Docs
![Chat avatar](https://platform.claude.com/docs/images/book-icon-light.svg)
