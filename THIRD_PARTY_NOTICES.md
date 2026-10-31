# Third-party notices

This repo vendors 12 skills unmodified from
[`databricks/databricks-agent-skills`](https://github.com/databricks/databricks-agent-skills)
into `skills/`, alongside this platform's own portfolio-specific skills:

`databricks-core`, `databricks-dabs`, `databricks-jobs`, `databricks-pipelines`,
`databricks-python-sdk`, `databricks-unity-catalog`, `databricks-dbsql`,
`databricks-spark-structured-streaming`, `databricks-lakeflow-connect`,
`databricks-serverless-migration`, `databricks-synthetic-data-gen`, `databricks-lakebase`.

Only `SKILL.md` and each skill's `references/`/`examples/`/`scripts/` content is included;
the upstream `agents/` (per-platform display metadata) and `assets/` (Databricks logo files)
folders are not vendored — not needed for how this platform uses them, and logo/trademark
assets shouldn't be redistributed as if generically available.

This is included, unmodified, as required by the license below:

> Copyright (2025) Databricks, Inc.
>
> This Software includes software developed at Databricks (https://www.databricks.com/) and its
> use is subject to the included LICENSE file.

## License (verbatim, applies to the 12 skills listed above only)

```
                               Databricks License
                        Copyright (2022) Databricks, Inc.

    Definitions.

    Agreement: The agreement between Databricks, Inc., and you governing
    the use of the Databricks Services, as that term is defined in
    the Master Cloud Services Agreement (MCSA) located at
    www.databricks.com/legal/mcsa.

    Licensed Materials: The source code, object code, data, and/or other
    works to which this license applies.

    Scope of Use. You may not use the Licensed Materials except in
    connection with your use of the Databricks Services pursuant to
    the Agreement. Your use of the Licensed Materials must comply at all
    times with any restrictions applicable to the Databricks Services,
    generally, and must be used in accordance with any applicable
    documentation. You may view, use, copy, modify, publish, and/or
    distribute the Licensed Materials solely for the purposes of using
    the Licensed Materials within or connecting to the Databricks Services.
    If you do not agree to these terms, you may not view, use, copy,
    modify, publish, and/or distribute the Licensed Materials.

    Redistribution. You may redistribute and sublicense the Licensed
    Materials so long as all use is in compliance with these terms.
    In addition:

        -   You must give any other recipients a copy of this License;
        -   You must cause any modified files to carry prominent notices
            stating that you changed the files;
        -   You must retain, in any derivative works that you distribute,
            all copyright, patent, trademark, and attribution notices,
            excluding those notices that do not pertain to any part of
            the derivative works; and
        -   If a "NOTICE" text file is provided as part of its
            distribution, then any derivative works that you distribute
            must include a readable copy of the attribution notices
            contained within such NOTICE file, excluding those notices
            that do not pertain to any part of the derivative works.

    You may add your own copyright statement to your modifications and may
    provide additional license terms and conditions for use, reproduction,
    or distribution of your modifications, or for any such derivative works
    as a whole, provided your use, reproduction, and distribution of
    the Licensed Materials otherwise complies with the conditions stated
    in this License.

    Termination. This license terminates automatically upon your breach of
    these terms or upon the termination of your Agreement. Additionally,
    Databricks may terminate this license at any time on notice. Upon
    termination, you must permanently delete the Licensed Materials and
    all copies thereof.

    DISCLAIMER; LIMITATION OF LIABILITY.

    THE LICENSED MATERIALS ARE PROVIDED "AS-IS" AND WITH ALL FAULTS.
    DATABRICKS, ON BEHALF OF ITSELF AND ITS LICENSORS, SPECIFICALLY
    DISCLAIMS ALL WARRANTIES RELATING TO THE LICENSED MATERIALS, EXPRESS
    AND IMPLIED, INCLUDING, WITHOUT LIMITATION, IMPLIED WARRANTIES,
    CONDITIONS AND OTHER TERMS OF MERCHANTABILITY, SATISFACTORY QUALITY OR
    FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT. DATABRICKS AND
    ITS LICENSORS TOTAL AGGREGATE LIABILITY RELATING TO OR ARISING OUT OF
    YOUR USE OF OR DATABRICKS' PROVISIONING OF THE LICENSED MATERIALS SHALL
    BE LIMITED TO ONE THOUSAND ($1,000) DOLLARS.  IN NO EVENT SHALL
    THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
    OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
    ARISING FROM, OUT OF OR IN CONNECTION WITH THE LICENSED MATERIALS OR
    THE USE OR OTHER DEALINGS IN THE LICENSED MATERIALS.
```

Scope-of-use note: the upstream license restricts use to Databricks Services. Redistribution retains that scope and the license text above.

**Do not modify** the 12 vendored skills in place — the license requires marking any changed
file as changed. If one needs an portfolio-specific adjustment, write it as a new skill in
`standards/`/`skills/<portfolio-name>/` that references the upstream one, the same way
`databricks-job-bundle` already complements (not replaces) `databricks-dabs`.

**Staying current**: these are a point-in-time copy, not re-synced automatically — re-run the
copy from [`databricks/databricks-agent-skills`](https://github.com/databricks/databricks-agent-skills)
periodically (see `CONTRIBUTING.md`) to pick up upstream updates.
