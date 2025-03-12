# Slurm-Engine

The **Slurm Engine** is a Shiny web application that allows users to generate SLURM job submission scripts and interactive SLURM commands. It is designed to simplify the process of submitting and running jobs on clusters using the SLURM workload manager.

## Features

- **Job Submission**: Generate SLURM job scripts with customizable options (job name, memory, CPUs, GPU request, and more).
- **Interactive Sessions**: Generate SLURM commands to run jobs interactively on the cluster.
- **Cheat Sheet**: A table of commonly used SLURM commands for quick reference.
- **Customizable Inputs**: Users can input job parameters such as job name, email, memory, CPUs, GPU requirements, and additional commands.
- **Downloadable Scripts**: Users can download the generated SLURM job script for easy submission.

## Prerequisites

Before running the application, ensure that you have the following installed on your system:

- **R** (version 4.0.0 or higher)
- **Shiny** package (`install.packages("shiny")`)
- **DT** package (`install.packages("DT")`)

## Installation

To use the Slurm Engine app locally, follow these steps:

1. Clone the repository:

   ```bash
   git clone https://github.com/yourusername/slurm-engine.git
   cd slurm-engine

2. Install needed packages
   install.packages(c("shiny", "DT"))

3. Run app
   library(shiny)
runApp("app_directory_path")  # Replace with your app directory path
