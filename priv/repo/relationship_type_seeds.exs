# Script for populating the database. You can run it as:
#
#     mix run priv/repo/relationship_type_seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Klepsidra.Repo.insert!(%Klepsidra.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Klepsidra.KnowledgeManagement

predefined_relationship_types = [
  %{
    name: "Relates to",
    description:
      "GENERAL: A generic connection, often used when a more specific relationship isn’t applicable", default: true
  },
  %{
    name: "Supports",
    description:
      "RESEARCH: Provides evidence or arguments that affirm the content of the destination note"
  },
  %{
    name: "Confirms",
    description: "RESEARCH: Verifies or validates an assertion made in another note"
  },
  %{
    name: "Refutes",
    description:
      "RESEARCH: Offers evidence or reasoning that disproves or challenges the destination note"
  },
  %{name: "Cites", description: "RESEARCH: Indicates a formal citation of a source"},
  %{
    name: "Defines",
    description: "SEMANTIC: Provides a definition or explanation of a term or concept"
  },
  %{
    name: "Elaborates",
    description:
      "RESEARCH: Provides additional detail, clarification, or expansion on the destination note"
  },
  %{name: "Parent of", description: "HIERARCHICAL: Represents hierarchical relationships"},
  %{name: "Child of", description: "HIERARCHICAL: Represents hierarchical relationships"},
  %{
    name: "Precedes",
    description:
      "HIERARCHICAL/CAUSAL: Indicates sequential relationships, particularly useful in workflows or chronological discussions"
  },
  %{
    name: "Follows",
    description:
      "HIERARCHICAL/CAUSAL: Indicates sequential relationships, particularly useful in workflows or chronological discussions."
  },
  %{
    name: "Example of",
    description:
      "HIERARCHICAL: Highlights that a note illustrates or exemplifies the concept in another note"
  },
  %{
    name: "Part of",
    description:
      "HIERARCHICAL: Indicates that the source note is a component or subsection of the destination note"
  },
  %{
    name: "Builds on",
    description: "GENERAL: The note expands upon or develops the idea from another note"
  },
  %{
    name: "Inspired by",
    description: "GENERAL: A note is created based on or influenced by the ideas in another note"
  },
  %{
    name: "Equivalent to",
    description: "ONTOLOGICAL: Marks two concepts or notes as semantically identical"
  },
  %{
    name: "Derived from",
    description: "ONTOLOGICAL: Indicates derivation or adaptation from a source."
  },
  %{
    name: "Type of",
    description: "ONTOLOGICAL: A taxonomic relationship (e.g., Dog is a type of Mammal)"
  },
  %{
    name: "Expands on",
    description: "SEMANTIC: Adds depth or breadth to an existing idea or note"
  },
  %{
    name: "Answers",
    description: "SEMANTIC: Directly responds to or resolves a question posed in another note"
  },
  %{
    name: "Questions",
    description: "SEMANTIC: Raises questions or doubts about the content of another note"
  },
  %{
    name: "Clarifies",
    description: "SEMANTIC: Offers additional insight or removes ambiguity from another note"
  },
  %{
    name: "Alias of",
    description: "GENERAL: Represents alternative names or synonyms for the same concept"
  },
  %{
    name: "Depends on",
    description:
      "GENERAL: Indicates a foundational dependency, such as the source note relying on the content of the target note"
  },
  %{
    name: "Similar to",
    description: "GENERAL: Indicates a conceptual or functional similarity between notes or ideas"
  },
  %{name: "Contrasts with", description: "GENERAL: Highlights a difference or opposing idea"},
  %{
    name: "Summarises",
    description: "RESEARCH: Provides a concise overview or abstraction of another note"
  },
  %{
    name: "Synthesizes",
    description: "RESEARCH: Combines ideas from multiple sources into a unified perspective"
  },
  %{
    name: "Causes",
    description:
      "CAUSAL: Identifies a causal relationship where one idea or event leads to another"
  },
  %{
    name: "Results in",
    description: "CAUSAL: Indicates an outcome or consequence stemming from the source note"
  },
  %{
    name: "Co-occurs with",
    description:
      "TEMPORAL: Notes two events or ideas that happen simultaneously or are strongly correlated"
  }
]

Enum.each(predefined_relationship_types, fn data ->
  KnowledgeManagement.create_relationship_type(data)
end)
