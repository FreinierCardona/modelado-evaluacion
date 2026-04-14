# SQL Layer Architecture

## Architectural Position

This repository is organized by SQL responsibility first, and by object family second.

That means:

- the first split is semantic: `DDL`, `DML`, `DCL`, `TCL`
- the second split is technical: tables, views, functions, grants, patches, and so on

This is a stronger model than placing everything under a generic `db/` folder or splitting only by object type from day one.

## Why `db/` Was Removed

At repository level, `db/` adds one more container but not one more meaning.

For a database-only project, the repository itself is already the database workspace.
Putting the active changelog under `db/` creates an extra hop without improving the architecture.

Keeping `changelog-master.yaml` at the root makes the deployment contract explicit and easier to audit.

## Layer Model

### 1. DDL

`01_ddl/` is the structural layer.

Use it for:

- extensions
- schemas
- types
- tables
- views
- materialized views
- functions
- procedures
- triggers
- indexes

Current active deployment lives here.

### 2. DML

`02_dml/` is the data manipulation layer.

Use it for:

- inserts
- updates
- deletes
- upserts
- one-time transformation patches

This layer should stay explicit and intentional, not mixed with structural changes.

For teams that need stronger operational traceability, organizing DML by primary verb is often better than organizing it only by business intent.

Recommended lanes:

- `02_dml/00_inserts`
- `02_dml/01_updates`
- `02_dml/02_deletes`
- `02_dml/03_upserts`
- `02_dml/04_patches`

### 3. DCL

`03_dcl/` is the access-control layer.

Use it for:

- roles
- grants
- policies

This is especially useful when environments differ in security posture and when permissions must be versioned separately from schema creation.

### 4. TCL

`04_tcl/` is the transaction-control layer.

Expert note:

In Liquibase-managed projects, `TCL` is usually minimal.
Liquibase already orchestrates execution boundaries, ordering, and transactional behavior for most changes.

So `TCL` should be treated as an exceptional lane, not a busy default lane.
It is still worth reserving for cases such as:

- manual recovery sequences
- exceptional transactional wrappers
- environment-specific operational scripts

## Practical Rule

Not every folder must be busy.
A good architecture is not one where every lane is full.
A good architecture is one where every lane has a clear meaning before the team needs it.

## Activation Rule

Only files included from `changelog-master.yaml` are part of the active deployment path.

Today, the live path is:

- `01_ddl/00_extensions`
- `01_ddl/01_schemas`
- `01_ddl/03_tables`

Everything else is reserved intentionally, not accidentally.

## Expert Recommendation

If the project stays small, keep the active flow concentrated in `DDL`.
When the project grows:

- promote data operations into explicit `DML` lanes
- promote security and grants into `DCL`
- keep `TCL` for exceptional operational cases only

That balance is typically cleaner than trying to force every concern into one flat directory tree.

## Rollback Reality For DML

An expert DBA distinction matters here:

- `DDL` is often mechanically reversible
- `DML` is often only logically reversible

That means:

- `INSERT` can often be reversed with a targeted `DELETE`
- `UPDATE` usually needs a compensating `UPDATE` or a pre-change snapshot
- `DELETE` usually needs recovery data, not just a rollback command

For that reason, DML governance should include:

- explicit tags before risky deployments
- SQL preview with `update-sql`
- compensation planning for `UPDATE` and `DELETE`
- avoiding blind trust in rollback for destructive data changes
