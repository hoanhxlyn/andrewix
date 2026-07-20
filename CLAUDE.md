# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal NixOS + Home Manager configuration (`andrewix`) using flake-parts with
the `vic/den` "dendritic" architecture. Every app/service/tool is declared as
a `core.<name>` aspect module, auto-discovered from `modules/` and composed
per-host/per-user by the `den` framework.

## Primary reference

**See [AGENTS.md](./AGENTS.md)** for commands, architecture, conventions, module patterns, and hard rules. This file only adds what `AGENTS.md` does not already cover.
