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
    reverse_name: "Relates to",
    description:
      "GENERAL: A generic connection, often used when a more specific relationship isn’t applicable",
    default: true
  },
  %{
    name: "Supports",
    reverse_name: "Supported by",
    description:
      "RESEARCH: Provides evidence or arguments that affirm the content of the destination note"
  },
  %{
    name: "Confirms",
    reverse_name: "Confirmed by",
    description: "RESEARCH: Verifies or validates an assertion made in another note"
  },
  %{
    name: "Refutes",
    reverse_name: "Refuted by",
    description:
      "RESEARCH: Offers evidence or reasoning that disproves or challenges the destination note"
  },
  %{
    name: "Cites",
    reverse_name: "Cited by",
    description: "RESEARCH: Indicates a formal citation of a source"
  },
  %{
    name: "Defines",
    reverse_name: "Defined by",
    description: "SEMANTIC: Provides a definition or explanation of a term or concept"
  },
  %{
    name: "Elaborates",
    reverse_name: "Elaborated by",
    description:
      "RESEARCH: Provides additional detail, clarification, or expansion on the destination note"
  },
  %{
    name: "Parent of",
    reverse_name: "Child of",
    description: "HIERARCHICAL: Represents hierarchical relationships"
  },
  %{
    name: "Child of",
    reverse_name: "Parent of",
    description: "HIERARCHICAL: Represents hierarchical relationships"
  },
  %{
    name: "Precedes",
    reverse_name: "Preceded by",
    description:
      "HIERARCHICAL/CAUSAL: Indicates sequential relationships, particularly useful in workflows or chronological discussions"
  },
  %{
    name: "Follows",
    reverse_name: "Followed by",
    description:
      "HIERARCHICAL/CAUSAL: Indicates sequential relationships, particularly useful in workflows or chronological discussions."
  },
  %{
    name: "Example of",
    reverse_name: "Example for",
    description:
      "HIERARCHICAL: Highlights that a note illustrates or exemplifies the concept in another note"
  },
  %{
    name: "Part of",
    reverse_name: "Comprises",
    description:
      "HIERARCHICAL: Indicates that the source note is a component or subsection of the destination note"
  },
  %{
    name: "Builds on",
    reverse_name: "Built upon by",
    description: "GENERAL: The note expands upon or develops the idea from another note"
  },
  %{
    name: "Inspired by",
    reverse_name: "Inspires",
    description: "GENERAL: A note is created based on or influenced by the ideas in another note"
  },
  %{
    name: "Equivalent to",
    reverse_name: "Equivalent to",
    description: "ONTOLOGICAL: Marks two concepts or notes as semantically identical"
  },
  %{
    name: "Derived from",
    reverse_name: "Source of",
    description: "ONTOLOGICAL: Indicates derivation or adaptation from a source."
  },
  %{
    name: "Type of",
    reverse_name: "Type for",
    description: "ONTOLOGICAL: A taxonomic relationship (e.g., Dog is a type of Mammal)"
  },
  %{
    name: "Expands on",
    reverse_name: "Expanded by",
    description: "SEMANTIC: Adds depth or breadth to an existing idea or note"
  },
  %{
    name: "Answers",
    reverse_name: "Answered by",
    description: "SEMANTIC: Directly responds to or resolves a question posed in another note"
  },
  %{
    name: "Questions",
    reverse_name: "Questioned by",
    description: "SEMANTIC: Raises questions or doubts about the content of another note"
  },
  %{
    name: "Clarifies",
    reverse_name: "Clarified by",
    description: "SEMANTIC: Offers additional insight or removes ambiguity from another note"
  },
  %{
    name: "Alias of",
    reverse_name: "Aliased by",
    description: "GENERAL: Represents alternative names or synonyms for the same concept"
  },
  %{
    name: "Depends on",
    reverse_name: "Depended on by",
    description:
      "GENERAL: Indicates a foundational dependency, such as the source note relying on the content of the target note"
  },
  %{
    name: "Similar to",
    reverse_name: "Similar to",
    description: "GENERAL: Indicates a conceptual or functional similarity between notes or ideas"
  },
  %{
    name: "Contrasts with",
    reverse_name: "Contrasts with",
    description: "GENERAL: Highlights a difference or opposing idea"
  },
  %{
    name: "Summarises",
    reverse_name: "Summarised by",
    description: "RESEARCH: Provides a concise overview or abstraction of another note"
  },
  %{
    name: "Synthesizes",
    reverse_name: "Synthesised by",
    description: "RESEARCH: Combines ideas from multiple sources into a unified perspective"
  },
  %{
    name: "Causes",
    reverse_name: "Caused by",
    description:
      "CAUSAL: Identifies a causal relationship where one idea or event leads to another"
  },
  %{
    name: "Results in",
    reverse_name: "Resulted from",
    description: "CAUSAL: Indicates an outcome or consequence stemming from the source note"
  },
  %{
    name: "Co-occurs with",
    reverse_name: "Co-occurs with",
    description:
      "TEMPORAL: Notes two events or ideas that happen simultaneously or are strongly correlated"
  }
]

Enum.each(predefined_relationship_types, fn data ->
  KnowledgeManagement.create_relationship_type(data)
end)
