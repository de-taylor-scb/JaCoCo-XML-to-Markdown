# JaCoCo XML to Markdown (Simple)

## DEPRECATED

This GitHub Action is being deprecated and archived. This is because it has been moved to [Prettify Pester Reports](https://github.com/Stylecraft-Builders/Prettify-Pester-Reports) owned by Stylecraft Builders.

## Copyright
This package was created by Dallas Taylor at Stylecraft Builders, and released publicly under a GPLv3 License. This package contains no code or information proprietary to Stylecraft Builders, and has no implied warranty.

## Summary
This is a GitHub Composite Action that will convert the coverage.xml (JaCoCo schema) generated from PowerShell Pester tests and convert it to Markdown for easy diplay on GitHub.

This GitHub Action takes a coverage.xml file in the JaCoCo schema and converts it for display in Markdown.

These Markdown tables are very simple, summarizing the JaCoCo XML in three levels:
 - Summary, coverage of all lines, instructions, methods, and classes
 - Coverage by Class (File), listing each class and its coverage by lines, instructions, methods, and classes
 - Coverage by Method, listing each method and its class, name, line number, and coverage by lines, instructions, and methods.

At this time, this Action does not support conversion of other Code Coverage report types, though if there is enough interest this may be expanded.

---

## Quick Start

To use this action in your own workflow, add the step below in your own Action:

```YAML
- name: Run JaCoCo XML to Markdown
  uses: de-taylor-scb/JaCoCo-XML-to-Markdown@v1.0.0
  with:
    path: .\reports\coverage.xml
    output: .\reports\coverage.md
```

The `coverage.xml` file should be an ouput from Pester, a unit testing framework for PowerShell, and it should be in the JaCoCo code coverage schema. This Action does not currently support any other schemas.

## Full Documentation 

### YAML

This section fully describes the expected and optional inputs for this Action.

```YAML
- name: Run JaCoCo XML to Markdown
  uses: de-taylor-scb/JaCoCo-XML-to-Markdown@v1.0.0
  with:
    path:
    output:
    title:
    maxHeadingLevel:
    minLinePercent:
    minInstructionPercent:
    minMethodPercent:
    minClassPercent:
```

### Inputs

Every input is of type string, however the last five inputs will be type cast to `integer` or `double` as indicated by their input definitions.

None of these inputs can take an array at this time.

#### `path`

Specifies the path for the coverage.xml file to convert to Markdown. This must be a file parsable as XML. This input defaults to `.\_results\coverage.xml`, which is the expected location for code coverage reports for my organization.

```YAML
with:
  path: .\_results\coverage.xml
```

```YAML
with:
  path: .\tests\coverage_test1.xml
```

#### `output`

Specifies the location of the Markdown output file. This input defaults to `.\_results\coverage.md`, which is the expected location for code coverage reports for my organization.

```YAML
with:
  output: .\_results\coverage.md
```

```YAML
with:
  output: .\tests\coverage_test1.md
```


#### `title`

Specifies the title of the Markdown Report. For example, providing the repository name. Defaults to "Code Coverage (JaCoCo)".

```YAML
with:
  title: 'Code Coverage (JaCoCo)'
```

```YAML
with:
  title: 'Test Code Coverage Report 1 (Failing) (JaCoCo)'
```

#### `maxHeadingLevel`

The topmost heading that should be included in the report. e.g. 1 for H1 (#), 2 for H2 (##), and so on. All other headings will be placed relative to the top level. Defaults to 3 (###).

This input was created so that Markdown reports could be produced at the appropriate subheading level, for example inside of an existing document.

This number corresponds to the number of '#' characters inserted into the Markdown for the highest-level subheading in this report.

```YAML
with:
  maxHeadingLevel: 3
```

```YAML
with:
  maxHeadingLevel: 1
```

#### `minLinePercent`

Specifies the minimum coverage threshold for lines. If the actual coverage is below this threshold, the action will fail.

```YAML
# fully permissive
with:
  minLinePercent: 0.0
```

```YAML
# requires 80%+ of lines to be tested
with:
  minLinePercent: 80.0
```

#### `minInstructionPercent`

Specifies the minimum coverage threshold for instructions. If the actual coverage is below this threshold, the action will fail.

```YAML
# fully permissive
with:
  minInstructionPercent: 0.0
```

```YAML
# requires 75%+ of instructions to be tested
with:
  minInstructionPercent: 75.0
```

#### `minMethodPercent`

Specifies the minimum coverage threshold for methods. If the actual coverage is below this threshold, the action will fail.

```YAML
# fully permissive
with:
  minMethodPercent: 0.0
```

```YAML
# requires 90%+ of methods to be tested
with:
  minMethodPercent: 90.0
```

#### `minClassPercent`

Specifies the minimum coverage threshold for classes. If the actual coverage is below this threshold, the action will fail.

```YAML
# fully permissive
with:
  minClassPercent: 0.0
```

```YAML
# requires 100%+ of methods to be tested
with:
  minClassPercent: 100.0
```

---

## Local Script Run Examples

Here are a few locally-run examples demonstrating the inputs and outputs. I have provided both the `tests\` and `_reports\` directories for reproducibility.

The `tests\` directory contains the sample `coverage.xml` input files.

The `_reports\` directory contains the sample `coverage.md` output files.

### Example 1: (Passing Thresholds)

**Command**

```PowerShell
.\Convert-XMLToMarkdown.ps1 `
    -Path .\tests\coverage_test2.xml `
    -Output .\_reports\coverage_test2.md `
    -Title "Test Code Coverage Report 2 (Passing) (JaCoCo)" `
    -MaxHeadingLevel 4 `
    -MinLinePercent 80.0 `
    -MinInstructionPercent 75.0 `
    -MinMethodPercent 70.0 `
    -MinClassPercent 100.0
```

**Output**
```Text
Build is passing, all coverage thresholds were met!
Markdown coverage written to: .\_reports\coverage_test2.md
```

**`coverage.xml`**

```XML
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!DOCTYPE report PUBLIC "-//JACOCO//DTD Report 1.1//EN" "report.dtd"[]>
<report name="Pester (12/03/2025 23:00:16)">
  <sessioninfo id="this" start="1764802813848" dump="1764802816427" />
  <package name="D:/a/Sample-ModuleName/Sample-ModuleName/src">
    <class name="D:/a/Sample-ModuleName/Sample-ModuleName/src/Utilities" sourcefilename="Utilities.ps1">
      <method name="&lt;script&gt;" desc="()" line="11">
        <counter type="INSTRUCTION" missed="2" covered="5" />
        <counter type="LINE" missed="2" covered="4" />
        <counter type="METHOD" missed="0" covered="1" />
      </method>
      <method name="Sample-Function1Name" desc="()" line="52">
        <counter type="INSTRUCTION" missed="0" covered="7" />
        <counter type="LINE" missed="0" covered="6" />
        <counter type="METHOD" missed="0" covered="1" />
      </method>
      <method name="Sample-Function2Name" desc="()" line="97">
        <counter type="INSTRUCTION" missed="0" covered="16" />
        <counter type="LINE" missed="0" covered="11" />
        <counter type="METHOD" missed="0" covered="1" />
      </method>
      <counter type="INSTRUCTION" missed="2" covered="28" />
      <counter type="LINE" missed="2" covered="21" />
      <counter type="METHOD" missed="0" covered="3" />
      <counter type="CLASS" missed="0" covered="1" />
    </class>
    <sourcefile name="Utilities.ps1">
      <line nr="11" mi="0" ci="1" mb="0" cb="0" />
      <line nr="13" mi="0" ci="2" mb="0" cb="0" />
      <line nr="14" mi="0" ci="1" mb="0" cb="0" />
      <line nr="17" mi="1" ci="0" mb="0" cb="0" />
      <line nr="20" mi="0" ci="1" mb="0" cb="0" />
      <line nr="22" mi="1" ci="0" mb="0" cb="0" />
      <line nr="52" mi="0" ci="1" mb="0" cb="0" />
      <line nr="54" mi="0" ci="1" mb="0" cb="0" />
      <line nr="56" mi="0" ci="1" mb="0" cb="0" />
      <line nr="59" mi="0" ci="2" mb="0" cb="0" />
      <line nr="61" mi="0" ci="1" mb="0" cb="0" />
      <line nr="65" mi="0" ci="1" mb="0" cb="0" />
      <line nr="97" mi="0" ci="2" mb="0" cb="0" />
      <line nr="99" mi="0" ci="2" mb="0" cb="0" />
      <line nr="102" mi="0" ci="1" mb="0" cb="0" />
      <line nr="103" mi="0" ci="1" mb="0" cb="0" />
      <line nr="105" mi="0" ci="1" mb="0" cb="0" />
      <line nr="106" mi="0" ci="3" mb="0" cb="0" />
      <line nr="107" mi="0" ci="1" mb="0" cb="0" />
      <line nr="108" mi="0" ci="1" mb="0" cb="0" />
      <line nr="111" mi="0" ci="1" mb="0" cb="0" />
      <line nr="113" mi="0" ci="2" mb="0" cb="0" />
      <line nr="115" mi="0" ci="1" mb="0" cb="0" />
      <counter type="INSTRUCTION" missed="2" covered="28" />
      <counter type="LINE" missed="2" covered="21" />
      <counter type="METHOD" missed="0" covered="3" />
      <counter type="CLASS" missed="0" covered="1" />
    </sourcefile>
    <counter type="INSTRUCTION" missed="2" covered="28" />
    <counter type="LINE" missed="2" covered="21" />
    <counter type="METHOD" missed="0" covered="3" />
    <counter type="CLASS" missed="0" covered="1" />
  </package>
  <counter type="INSTRUCTION" missed="2" covered="28" />
  <counter type="LINE" missed="2" covered="21" />
  <counter type="METHOD" missed="0" covered="3" />
  <counter type="CLASS" missed="0" covered="1" />
</report>
```

**Sample Markdown Output**

#### Test Code Coverage Report 2 (Passing) (JaCoCo)

**Report:** Pester (12/03/2025 23:00:16)

##### Summary
| Scope | Lines | Instructions | Methods | Classes |
| :--- | ---: | ---: | ---: | ---: |
| Total | 21/23 (91.3%) | 28/30 (93.3%) | 3/3 (100%) | 1/1 (100%) |

##### Coverage by Class
| Class | Lines | Instructions | Methods | Classes |
| :--- | ---: | ---: | ---: | ---: |
| D:/a/Sample-ModuleName/Sample-ModuleName/src/Utilities | 21/23 (91.3%) | 28/30 (93.3%) | 3/3 (100%) | 1/1 (100%) |

##### Coverage by Method
| Class | Method | Line | Lines | Instructions | Methods |
| :--- | :--- | ---: | ---: | ---: | ---: |
| D:/a/Sample-ModuleName/Sample-ModuleName/src/Utilities | &lt;script&gt; | 11 | 4/6 (66.7%) | 5/7 (71.4%) | 1/1 (100%) |
| D:/a/Sample-ModuleName/Sample-ModuleName/src/Utilities | Sample-Function1Name | 52 | 6/6 (100%) | 7/7 (100%) | 1/1 (100%) |
| D:/a/Sample-ModuleName/Sample-ModuleName/src/Utilities | Sample-Function2Name | 97 | 11/11 (100%) | 16/16 (100%) | 1/1 (100%) |

##### ✅ Coverage Thresholds Passed!
> Build is passing, all coverage thresholds were met!


### Example 2: (Failing Thresholds)

**Command**

```PowerShell
.\Convert-XMLToMarkdown.ps1 `
    -Path .\tests\coverage_test1.xml `
    -Output .\_reports\coverage_test1.md `
    -Title "Test Code Coverage Report 1 (Failing) (JaCoCo)" `
    -MaxHeadingLevel 4 `
    -MinLinePercent 80.0 `
    -MinInstructionPercent 75.0 `
    -MinMethodPercent 70.0 `
    -MinClassPercent 100.0
```

**Output**
```Text
Write-Error: Coverage thresholds not met: Line coverage 10% < min 80%; Instruction coverage 7.7% < min 75%; Method coverage 33.3% < min 70%
Markdown coverage written to: .\_reports\coverage_test1.m
```

**`coverage.xml`**

```XML
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!DOCTYPE report PUBLIC "-//JACOCO//DTD Report 1.1//EN" "report.dtd"[]>
<report name="Pester (12/03/2025 21:20:51)">
  <sessioninfo id="this" start="1764796849965" dump="1764796851035" />
  <package name="D:/a/Sample-ModuleName/Sample-ModuleName/src">
    <class name="D:/a/Sample-ModuleName/Sample-ModuleName/src/Utilities" sourcefilename="Utilities.ps1">
      <method name="&lt;script&gt;" desc="()" line="10">
        <counter type="INSTRUCTION" missed="1" covered="2" />
        <counter type="LINE" missed="1" covered="2" />
        <counter type="METHOD" missed="0" covered="1" />
      </method>
      <method name="Sample-Function1Name" desc="()" line="44">
        <counter type="INSTRUCTION" missed="7" covered="0" />
        <counter type="LINE" missed="6" covered="0" />
        <counter type="METHOD" missed="1" covered="0" />
      </method>
      <method name="Sample-Function2Name" desc="()" line="89">
        <counter type="INSTRUCTION" missed="16" covered="0" />
        <counter type="LINE" missed="11" covered="0" />
        <counter type="METHOD" missed="1" covered="0" />
      </method>
      <counter type="INSTRUCTION" missed="24" covered="2" />
      <counter type="LINE" missed="18" covered="2" />
      <counter type="METHOD" missed="2" covered="1" />
      <counter type="CLASS" missed="0" covered="1" />
    </class>
    <sourcefile name="Utilities.ps1">
      <line nr="10" mi="0" ci="1" mb="0" cb="0" />
      <line nr="12" mi="1" ci="0" mb="0" cb="0" />
      <line nr="14" mi="0" ci="1" mb="0" cb="0" />
      <line nr="44" mi="1" ci="0" mb="0" cb="0" />
      <line nr="46" mi="1" ci="0" mb="0" cb="0" />
      <line nr="48" mi="1" ci="0" mb="0" cb="0" />
      <line nr="51" mi="2" ci="0" mb="0" cb="0" />
      <line nr="53" mi="1" ci="0" mb="0" cb="0" />
      <line nr="57" mi="1" ci="0" mb="0" cb="0" />
      <line nr="89" mi="2" ci="0" mb="0" cb="0" />
      <line nr="92" mi="2" ci="0" mb="0" cb="0" />
      <line nr="95" mi="1" ci="0" mb="0" cb="0" />
      <line nr="96" mi="1" ci="0" mb="0" cb="0" />
      <line nr="98" mi="1" ci="0" mb="0" cb="0" />
      <line nr="99" mi="3" ci="0" mb="0" cb="0" />
      <line nr="100" mi="1" ci="0" mb="0" cb="0" />
      <line nr="101" mi="1" ci="0" mb="0" cb="0" />
      <line nr="104" mi="1" ci="0" mb="0" cb="0" />
      <line nr="106" mi="2" ci="0" mb="0" cb="0" />
      <line nr="108" mi="1" ci="0" mb="0" cb="0" />
      <counter type="INSTRUCTION" missed="24" covered="2" />
      <counter type="LINE" missed="18" covered="2" />
      <counter type="METHOD" missed="2" covered="1" />
      <counter type="CLASS" missed="0" covered="1" />
    </sourcefile>
    <counter type="INSTRUCTION" missed="24" covered="2" />
    <counter type="LINE" missed="18" covered="2" />
    <counter type="METHOD" missed="2" covered="1" />
    <counter type="CLASS" missed="0" covered="1" />
  </package>
  <counter type="INSTRUCTION" missed="24" covered="2" />
  <counter type="LINE" missed="18" covered="2" />
  <counter type="METHOD" missed="2" covered="1" />
  <counter type="CLASS" missed="0" covered="1" />
</report>
```

**Sample Markdown Output**

#### Test Code Coverage Report 1 (Failing) (JaCoCo)

**Report:** Pester (12/03/2025 21:20:51)

##### Summary
| Scope | Lines | Instructions | Methods | Classes |
| :--- | ---: | ---: | ---: | ---: |
| Total | 2/20 (10%) | 2/26 (7.7%) | 1/3 (33.3%) | 1/1 (100%) |

##### Coverage by Class
| Class | Lines | Instructions | Methods | Classes |
| :--- | ---: | ---: | ---: | ---: |
| D:/a/Sample-ModuleName/Sample-ModuleName/src/Utilities | 2/20 (10%) | 2/26 (7.7%) | 1/3 (33.3%) | 1/1 (100%) |

##### Coverage by Method
| Class | Method | Line | Lines | Instructions | Methods |
| :--- | :--- | ---: | ---: | ---: | ---: |
| D:/a/Sample-ModuleName/Sample-ModuleName/src/Utilities | &lt;script&gt; | 10 | 2/3 (66.7%) | 2/3 (66.7%) | 1/1 (100%) |
| D:/a/Sample-ModuleName/Sample-ModuleName/src/Utilities | Sample-Function1Name | 44 | 0/6 (0%) | 0/7 (0%) | 0/1 (0%) |
| D:/a/Sample-ModuleName/Sample-ModuleName/src/Utilities | Sample-Function2Name | 89 | 0/11 (0%) | 0/16 (0%) | 0/1 (0%) |

##### ❌ Coverage Thresholds Failed
- Line coverage 10% < min 80%
- Instruction coverage 7.7% < min 75%
- Method coverage 33.3% < min 70%

> Build failed due to coverage thresholds.
