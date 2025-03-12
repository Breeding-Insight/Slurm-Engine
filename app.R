library(shiny)
library(DT)

# Define UI for SLURM script generator with tabs
ui <- fluidPage(
  # Main title
  div(
    style = "font-size: 32px; font-weight: bold; text-align: center; margin-bottom: 20px;",
    "BI Slurm Engine"
  ),
  
  # Tab layout
  tabsetPanel(
    # Job Submission tab
    tags$div(
      style = "text-align: center; margin-bottom: 20px;",
      tags$img(src = "logos.png", alt = "BI Logo", style = "max-width: 35%; height: auto;")
    ),
    
    tabPanel(
      HTML("<b>Generate code to submit your job</b>"),
      wellPanel(
        style = "background-color: #f8f9fa; padding: 15px; border-radius: 5px;",
        h4("Some info before you start"),
        h5("Check available resources"),
        tags$li("Always check available resources with ", code("sinfo"), " before submitting a job."),
        h5("General guidelines for RAM per core:"),
        tags$ul(
          tags$li("Lightweight Jobs: 2-4 GB of RAM per core."),
          tags$li("Memory-Intensive Jobs: 8-16 GB of RAM per core."),
          tags$li("Very High RAM Jobs: you may need to allocate more than 16 GB per core (e.g., 32 GB or more per core).")
        ),
        h5("Determining the number of cores:"),
        tags$ul(
          tags$li("Single-threaded jobs: If your job is single-threaded, allocate only 1 core."),
          tags$li("Multi-threaded jobs: For parallel jobs, allocate as many cores as there are threads in your job.")
        ),
        h5("Using programs in your job:"),
        tags$ul(
          tags$li("Check for programs preinstalled in biohpc",
                  tags$a("here", href = "https://biohpc.cornell.edu/lab/labsoftware.aspx", target = "_blank")),
          tags$li("If your program or specific version is not there, slack", 
                  tags$a("biohpc_servers", href = "https://bi-internal.slack.com/archives/C03CX3S473P", target = "_blank")),
          
        )
      ),
      

      titlePanel("SLURM Script Generator"),
      sidebarLayout(
        sidebarPanel(
          textInput("job_name", "Job Name:", "my_job"),
          textInput("email", "Email address:", "@cornell.edu"),
          numericInput("memory", "Memory (GB):", 4, min = 1),
          numericInput("cpus", "Number of CPUs:", 1, min = 1),
          checkboxInput("gpu", "Request GPU", FALSE),
          textAreaInput("commands", "Commands to Run:", "", rows = 4),
          downloadButton("download_script", "Download SLURM Script")
        ),
        mainPanel(
          h4("Generated SLURM Script:"),
          verbatimTextOutput("slurm_script")
        )
      )
    ),
    
    # Interactive Session tab

    tabPanel(
      HTML("<b>Run Your Code Interactively</b>"),
      wellPanel(
        style = "background-color: #f8f9fa; padding: 15px; border-radius: 5px;",
        h4("Some info before you start"),
        h5("Check available resources"),
        tags$li("Always check available resources with ", code("sinfo"), " before submitting a job."),
        h5("General guidelines for RAM per core:"),
        tags$ul(
          tags$li("Lightweight Jobs: 2-4 GB of RAM per core."),
          tags$li("Memory-Intensive Jobs: 8-16 GB of RAM per core."),
          tags$li("Very High RAM Jobs: you may need to allocate more than 16 GB per core (e.g., 32 GB or more per core).")
        ),
        h5("Determining the number of cores:"),
        tags$ul(
          tags$li("Single-threaded jobs: If your job is single-threaded, allocate only 1 core."),
          tags$li("Multi-threaded jobs: For parallel jobs, allocate as many cores as there are threads in your job.")
        ),
        h5("Using programs in your job:"),
        tags$ul(
          tags$li("Check for programs preinstalled in biohpc",
                  tags$a("here", href = "https://biohpc.cornell.edu/lab/labsoftware.aspx", target = "_blank")),
          tags$li("If your program or specific version is not there, slack", 
                  tags$a("biohpc_servers", href = "https://bi-internal.slack.com/archives/C03CX3S473P", target = "_blank")),
          
        )
      ),
      
    
      titlePanel("Interactive SLURM Session"),
      sidebarLayout(
        sidebarPanel(
          textInput("interactive_job_name", "Job Name:", "interactive_test"),
          textInput("interactive_email", "Email address:", "@cornell.edu"),
          numericInput("interactive_memory", "Memory (GB):", 40, min = 1),
          numericInput("interactive_cpus", "Number of CPUs:", 4, min = 1),
          checkboxInput("interactive_gpu", "Request GPU", FALSE)
        ),
        mainPanel(
          h4("Generated Interactive SLURM Command:"),
          verbatimTextOutput("interactive_command")
        )
      )
    ),
    
    # Cheat Sheet tab

    
    tabPanel(
      HTML("<b>Cheat Sheet</b>"),
      titlePanel("Useful Commands"),
      mainPanel(
        DT::dataTableOutput("cheat_sheet_table")
      )
    )
  ) # Closing tabsetPanel
)

server <- function(input, output) {
  
  # Render the generated SLURM script
  output$slurm_script <- renderText({
    job_name <- input$job_name
    email <- input$email
    memory <- input$memory
    cpus <- input$cpus
    gpu <- ifelse(input$gpu, "--gres=gpu:1", "")
    commands <- input$commands
    
    script <- paste0(
      "#!/bin/bash\n",
      "#SBATCH --job-name=", job_name, "\n",
      "#SBATCH --output=", job_name, "_%j.out\n",
      "#SBATCH --error=", job_name, "_%j.err\n",
      "#SBATCH --mail-type=ALL\n",
      "#SBATCH --mail-user=", email, "\n",
      "#SBATCH --mem=", memory, "G\n",
      "#SBATCH --cpus-per-task=", cpus, "\n",
      gpu, "\n",
      "\n", commands
    )
    return(script)
  })
  
  # Render the generated interactive SLURM command
  output$interactive_command <- renderText({
    job_name <- input$interactive_job_name
    email <- input$interactive_email
    memory <- input$interactive_memory
    cpus <- input$interactive_cpus
    gpu <- ifelse(input$interactive_gpu, "--gres=gpu:1", "")
    
    command <- paste0(
      "srun --job-name=", job_name, " ",
      "--mem=", memory, "G ",
      "--cpus-per-task=", cpus, " ",
      gpu, " ",
      "--mail-user=", email, " ",
      "bash"
    )
    return(command)
  })
  
  # Cheat Sheet table
  output$cheat_sheet_table <- DT::renderDataTable({
    data.frame(
      Command = c(
        "sinfo -o '%P %C %m %n %f'",
        "sbatch my_script.sh",
        "scontrol update jobid=xxxx TimeLimit=DD-HH:MM:SS",
        "screen -S <name>",
        "screen -ls",
        "screen -x",
        "screen -r <name>",
        "screen -dRR",
        "screen -d <name>",
        "sacct -j <jobid> --format=JobID,JobName,MaxRSS,ReqMem,Elapsed --units=G"
      ),
      Function = c(
        "Check available resources, CPU counts are allocated/idle/other/total.",
        "Submit a job script to SLURM",
        "Extend the time of your resource allocation",
        "Start a new screen session with a session name",
        "List running sessions/screens",
        "Attach to a running session",
        "Attach to a running session with a specific name",
        "Attach to a screen session (detaching any existing attachments, creating one if none exist)",
        "Detach a running session",
        "Display SLURM job resource usage: memory, runtime, and job details"
      )
    )
  })
}

shinyApp(ui = ui, server = server)