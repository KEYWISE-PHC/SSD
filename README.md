(CMP-X306-0) Secure Software Development
# CSWRK: PASSWORD HYGIENE COACH
### Written by. Mahbouba, Keisha, Maahia, Hala & Artem

## G6-SAD Group Member Details
- Mahbouba Rezaei (REZ23579670) [GitHub Profile](https://github.com/M12rezaei)
- Keisha Geyrozaga (GEY23581805) [GitHub Profile](https://github.com/MOMORII)
- Maahia Rahman (RAH23614335) [GitHub Profile](https://github.com/maahiarahman)
- Hala Bakhtiar (BAK23592238) [GitHub Profile](https://github.com/BAK23592238)
- Artem Shkurat (SHK22612576) [GitHub Profile](https://github.com/ArtemShkurat)

  
## Repository Information
This repository contains the development of our S.S.D GROUP COURSEWORK ASSIGNMENT 'PASSWORD HYGIENE COACH'. The project is built in Flutter using Dart as our main programming language for backend work & Visual Studio Code (VSC), it follows professional development practices. In addition to this, we have included numerous files evidencing our commitment to producing well-structured, organised deliverables. Using a Kanban board, we allocated tasks between us fairly and equally amongst ourselves.

All information below comprises all relevant project information from both our solution design document (SDD) & supporting module content.

## Project Overview
The following information will aim to summarise project information in accordance with the 'Secure Software Development' assignment specification. Our project team consists of five members that collaboratively developed a password hygiene coach (PHC) as a mobile application built with Flutter, written in Dart within Visual Studio Code (VSC), and a local SQLite database (DB).

### Team Member Roles:
- **SECURITY LEAD** (Mahbouba) – Responsible for leading threat modelling process and testing efforts, as well as reviewing codebase, & conducting system vulnerability checks, plus SQL

- **DOCUMENTATION LEAD** (Keisha) – Led the creation/organisation of project management tools, handled task allocation, in addition to the drafting, editing & formatting of all documentation 

- **DEVELOPMENT TEAM** (Hala, Maahia, Artem) – Focused collective efforts on the full-stack, backend, and frontend development of the mobile application, polishing the UI layout, & the bulk of code tasks 

### Project Summary
This document intends to outline the design of a ‘PASSWORD HYGEINE COACH’ that will help users generate strong passwords, assess strength, and adopt effective password protection practices without sending secrets to a server. We aim to be able to create a user-centred mobile software application that allows us to teach users how to effectively deploy secure passwords, assess user-suggested password strength/security, & help users deploy password protection practices into their day-to-day lives.

### Core Features
1. Offline password generator with adjustable length and character sets.
2. Strength meter with clear feedback (entropy estimate, common patterns).
3. Micro-lessons: short tips on MFA, phishing, and password managers.

### Key Architectural Characteristics
-	Cross-platform build using Flutter SDK
-	Local data storage via SQLite (via sqflite plugin)
-	No backend server or network requests
-	Strictly local operations to reduce attack surface
-	Depends on third-party libraries to function

### Security Requirements
-	All processing to be done locally on the user’s device; ensure passwords are never stored by default
- No network calls, unless user explicitly enables the breach-check feature
- Clear privacy screen for app switching

### Non-Functional Requirements 
We aim to implement basic accessibility support and ensure our mobile application is battery-friendly, as well as, lightweight.

### Technology Stack
This details the technology stack we aim to implement into our FRONTEND, BACKEND, APIs, & PROJECT MANAGEMENT TOOLS.
-	Flutter for cross-platform.
-	Secure random source via platform APIs
-	GitHub Project and Kanban Boards as our main PM tools

### Chosen Methodology
The assessment follows a software supply chain threat-modelling methodology that includes…

-	SBOM generation using Syft
-	Software Composition Analysis (SCA) using Trivy & Dependency-Check
-	STRIDE-based threat identification adapted to dependency & build risks
-	CVE mapping & CVSS scoring for relevant native/third-party vulnerabilities
-	Consolidated supply-chain risk register/matrix

This methodology focuses on the internal attack vectors and possible vulnerabilities of third-party packages that can impact the app’s integrity, even in its offline state.

### Development Approach
We are following the 'Scrum' methodology, using GitHub Project for task management and sprint tracking. Our main programming language will be done within 'Flutter' and 'Visual Studio Code' will be the IDE we develop the program in. Our team aims to maintain regular communications through a WhatsApp groupchat for quick updates on current progress, and, 'Microsoft Teams' for weekly team meetings.

## Kanban board
This is the Kanban board we use to track progress, organise tasks, and ensure smooth workflow management. Each column represents a different stage of the process, helping us visualise work in progress and prioritise tasks effectively. [SSD KANBAN BOARD](https://github.com/users/MOMORII/projects/3/views/1?system_template=kanban)

## Conclusion
As a team, we were able to effectively distribute task responsibilities amongst ourselves and work towards meeting our weekly planned objectives outlined in the coursework assignment brief. Through clear and consistent communication via WhatsApp and Microsoft Teams, we utilised GitHub, VSC, and Flutter to achieve our development goals efficiently.
