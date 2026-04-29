# OpenCode Workflow Diagram

Mermaid version of the 3-level company hierarchy workflow.

## Main Diagram

```mermaid
flowchart LR
    U[User request] --> C[CTO<br/>GPT 5.5<br/>orchestrator]

    C --> T{Trivial or<br/>planning only?}
    T -->|Yes| D[Handle directly<br/>or plan]
    D --> R[Respond to user]

    T -->|No| DLEG{Task type?}

    DLEG -->|Complex /<br/>architecture /<br/>review| S[Senior DEV<br/>GPT 5.5<br/>subagent]

    DLEG -->|Routine /<br/>implementation /<br/>tests / ops| M[Mid DEV<br/>DeepSeek V4 Pro<br/>subagent]

    S --> SD{Needs<br/>implementation?}
    SD -->|Yes| M2[Mid DEV<br/>implements]
    SD -->|No| S2[Senior handles<br/>directly]
    M2 --> S
    S2 --> C

    M --> C
    S --> C

    C --> F{Files<br/>changed?}
    F -->|No| R
    F -->|Yes| RV[Senior DEV<br/>final review]
    RV --> P{Issues?}
    P -->|Yes| FIX[Fix via Mid DEV]
    FIX --> RV
    P -->|No| R

    classDef cto fill:#FF6B6B,stroke:#1c1c1c,color:#1c1c1c;
    classDef senior fill:#4ECDC4,stroke:#1c1c1c,color:#1c1c1c;
    classDef mid fill:#45B7D1,stroke:#1c1c1c,color:#1c1c1c;
    classDef neutral fill:#F1F3F5,stroke:#1c1c1c,color:#1c1c1c;

    class C,D,F,R cto;
    class S,S2,RV senior;
    class M,M2,FIX mid;
    class T,DLEG,SD,P neutral;
```

## Reading Guide

- User talks to **CTO**.
- **CTO** handles simple work directly, delegates everything else.
- Complex/architecture/review tasks go to **Senior DEV** (GPT 5.5).
- Routine implementation/tests/ops go to **Mid DEV** (DeepSeek V4 Pro).
- **Senior DEV** can delegate implementation subtasks to **Mid DEV**.
- All results flow back to **CTO** for final integration.

## Core Message

CTO (GPT 5.5) steers. Senior DEV (GPT 5.5) decides complex things. Mid DEV (DeepSeek V4 Pro) does the work. Expensive models used sparingly for high-value decisions.
