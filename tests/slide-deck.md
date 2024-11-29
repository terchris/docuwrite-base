---
marp: true
theme: default
paginate: true
---

# Test Presentation
Created for testing Marp CLI conversion

---

## What is this?
This is a test slide deck for verifying:
* Marp installation
* PDF conversion
* Theme application
* Basic formatting

---

## Code Example
```python
def hello():
    print("Hello from test deck!")
```

---

<!-- Split layout with columns -->
## Mermaid Diagram

<div class="columns">
<div>

Here's the Mermaid code that generates the diagram:

```mermaid
graph TD
    A[Support Case Opened] --> B[Initial Review]
    B --> C{Priority?}
    C -->|High| D[Immediate Response]
    C -->|Medium| E[24 Hour Response]
    C -->|Low| F[48 Hour Response]
    D --> G[Notify Team Lead]
    E --> H[Queue for Assignment]
    F --> H
    G --> I[Begin Resolution]
    H --> I
    I --> J{Resolved?}
    J -->|Yes| K[Close Case]
    J -->|No| L[Escalate]
    L --> I
```

</div>
<div>

The rendered diagram:

![](mermaid-diagram.png)

</div>
</div>

<style>
.columns {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 1rem;
}
</style>

---

## Logo Example
![width:400px](docuwrite-logo.png)

---

## Table Example
| Item | Description |
|------|-------------|
| Test 1| First test |
| Test 2| Second test|

---

# Thank You
End of test presentation