# Godot Project Folder

This directory contains the Godot project for the Meta Quest 3S game.

## Contents

- `project.godot` — project configuration
- `scenes/` — XR and gameplay scenes
- `scripts/` — GDScript source files
- `addons/` — optional plugins and extensions
- `assets/` — project-local assets if needed

## Purpose

This folder is intended to hold the playable game project while the repository root stores shared documentation, assets, and build-related files.

## Initial goal

Create the smallest possible OpenXR-ready project that can:
- launch on Meta Quest 3S
- initialize VR correctly
- track headset and controllers
- render a basic test room

## Current starter scene

- Main scene: `res://scenes/Main.tscn`
- XR bootstrap script: `res://scripts/xr_bootstrap.gd`
