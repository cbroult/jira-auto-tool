# Overall Class Diagram Structure

```mermaid
classDiagram
    class Tool {
    }
    
    class BoardController {
    }
    
    class SprintController {
    }
    
    class BoardOptions {
        +add(tool, parser)$
    }
    
    class SprintOptions {
        +add(tool, parser)$
        +add_sprint_adding_options(parser, tool)$
        +add_sprint_listing_options(parser, tool)$
        +add_sprint_prefix_listing_options(parser, tool)$
    }
    
    class UntilDate {
    }
    
    class Cache {
    }

    Tool --> BoardController : has
    Tool --> SprintController : has
    BoardController --> BoardOptions : uses
    SprintController --> SprintOptions : uses
    BoardController --> Cache : uses
    SprintOptions --> UntilDate : uses

    %% Namespace structure
    namespace Jira {
        namespace Auto {
            Tool
            namespace Tool {
                BoardController
                SprintController
            }
        }
    }
```