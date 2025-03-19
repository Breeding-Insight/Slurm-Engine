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
    tabPanel(
      HTML("<b>Generate code to submit your job</b>"),
      fluidPage(
        wellPanel(
          style = "background-color: #f8f9fa; padding: 15px; border-radius: 5px;",
          h4("Geberal Rules of Thumb"),
          h5("Check available resources"),
          tags$li("Always check available resources with ", code("sinfo"), " before submitting a job."),
          h5("General Guidelines for RAM per Core:"),
          tags$ul(
            tags$li("Lightweight Jobs: 2-4 GB of RAM per core."),
            tags$li("Memory-Intensive Jobs: 8-16 GB of RAM per core."),
            tags$li("Very High RAM Jobs: you may need to allocate more than 16 GB per core (e.g., 32 GB or more per core).")
          ),
          h5("Determining the Number of Cores:"),
          tags$ul(
            tags$li("Single-threaded jobs: If your job is single-threaded, allocate only 1 core."),
            tags$li("Multi-threaded jobs: For parallel jobs, allocate as many cores as there are threads in your job.")
          )
        ),
        
        tags$div(
          style = "text-align: center; margin-bottom: 20px;",
          tags$img(src = "logos.png", alt = "BI Logo", style = "max-width: 35%; height: auto;")
        ),
        titlePanel("SLURM Script Generator"),
        sidebarLayout(
          sidebarPanel(
            textInput("job_name", "Job Name:", "my_job"),
            textInput("email", "Email address:", "@cornell.edu"),
            
            tags$div(
              style = "display: flex; align-items: center; gap: 10px;",
              tags$label("Time:", style = "font-weight: bold;"),
              numericInput("days", "Days", 0, min = 0, width = "80px"),
              numericInput("hours", "Hours", 0, min = 0, max = 23, width = "80px"),
              numericInput("minutes", "Minutes", 0, min = 0, max = 59, width = "80px")
            ),
            
            numericInput("memory", "Memory (GB):", 4, min = 1),
            numericInput("cpus", "Number of CPUs:", 1, min = 1),
            checkboxInput("gpu", "Request GPU", FALSE),
            
            fluidRow(
              tags$p("Receive an email when your job:"),
              checkboxInput("begin", "Begins", FALSE),
              checkboxInput("end", "Ends", FALSE),
              checkboxInput("fail", "Fails", FALSE)
            ),
            textAreaInput("commands", "Commands to Run:"),
            downloadButton("download_script", "Download SLURM Script")
          ),
          mainPanel(
            h4("Generated SLURM Script:"),
            verbatimTextOutput("slurm_script")
          )
        )
      )
    ),
    
    # Interactive Session tab
    tabPanel(
      HTML("<b>Run Your Code Interactively</b>"),
      fluidPage(
        wellPanel(
          style = "background-color: #f8f9fa; padding: 15px; border-radius: 5px;",
          h4("Geberal Rules of Thumb"),
          h5("Check available resources"),
          tags$li("Always check available resources with ", code("sinfo"), " before submitting a job."),
          h5("General Guidelines for RAM per Core:"),
          tags$ul(
            tags$li("Lightweight Jobs: 2-4 GB of RAM per core."),
            tags$li("Memory-Intensive Jobs: 8-16 GB of RAM per core."),
            tags$li("Very High RAM Jobs: you may need to allocate more than 16 GB per core (e.g., 32 GB or more per core).")
          ),
          h5("Determining the Number of Cores:"),
          tags$ul(
            tags$li("Single-threaded jobs: If your job is single-threaded, allocate only 1 core."),
            tags$li("Multi-threaded jobs: For parallel jobs, allocate as many cores as there are threads in your job.")
          )
        ),
        
        tags$div(
          style = "text-align: center; margin-bottom: 20px;",
          tags$img(src = "logos.png", alt = "BI Logo", style = "max-width: 35%; height: auto;")
        ),
        titlePanel("Interactive SLURM Session"),
        sidebarLayout(
          sidebarPanel(
            textInput("interactive_job_name", "Job Name:", "interactive_test"),
            textInput("interactive_email", "Email address:", "@cornell.edu"),
            
            tags$div(
              style = "display: flex; align-items: center; gap: 10px;",
              tags$label("Time:", style = "font-weight: bold;"),
              numericInput("interactive_days", "Days", 0, min = 0, width = "80px"),
              numericInput("interactive_hours", "Hours", 5, min = 0, max = 23, width = "80px"),
              numericInput("interactive_minutes", "Minutes", 0, min = 0, max = 59, width = "80px")
            ),
            
            numericInput("interactive_memory", "Memory (GB):", 40, min = 1),
            numericInput("interactive_cpus", "Number of CPUs:", 4, min = 1),
            checkboxInput("interactive_gpu", "Request GPU", FALSE),
            
            fluidRow(
              tags$p("Receive an email when your session:"),
              checkboxInput("interactive_begin", "Begins", FALSE),
              checkboxInput("interactive_end", "Ends", FALSE),
              checkboxInput("interactive_fail", "Fails", FALSE)
            )
          ),
          mainPanel(
            h4("Generated Interactive SLURM Command:"),
            verbatimTextOutput("interactive_command")
          )
        )
      )
    ),
    
    # Cheat Sheet tab (moved inside tabsetPanel)
    tabPanel(
      HTML("<b>Cheat Sheet</b>"),
      fluidPage(
        tags$div(
          style = "text-align: center; margin-bottom: 20px;",
          tags$img(src = "logos.png", alt = "BI Logo", style = "max-width: 35%; height: auto;")
        ),
        titlePanel("Useful Commands"),
        mainPanel(
          DT::dataTableOutput("cheat_sheet_table")
        )
      )
    )
  ) # Closing tabsetPanel
)


# Define server logic
server <- function(input, output) {
  output$interactive_command <- renderText({
    mail_types <- c()
    if (input$interactive_begin) mail_types <- c(mail_types, "BEGIN")
    if (input$interactive_end) mail_types <- c(mail_types, "END")
    if (input$interactive_fail) mail_types <- c(mail_types, "FAIL")
    mail_type_str <- if (length(mail_types) > 0) paste(mail_types, collapse = ",") else ""
    
    total_time <- sprintf("%d-%02d:%02d:00",
                          input$interactive_days,
                          input$interactive_hours,
                          input$interactive_minutes)
    
    gpu_option <- if (input$interactive_gpu) " --gres=gpu:1" else ""
    
    command <- paste0(
      "# Interactive SLURM session command:\n",
      "salloc ",
      "--job-name=", input$interactive_job_name,
      " --ntasks=1",
      " --cpus-per-task=", input$interactive_cpus,
      " --mem=", input$interactive_memory, "G",
      " --time=", total_time,
      gpu_option,
      if (nzchar(input$interactive_email)) paste0(" \\\n--mail-user=", input$interactive_email) else "",
      if (nzchar(mail_type_str)) paste0(" --mail-type=", mail_type_str) else ""
    )
    
    command
  })
  
  output$slurm_script <- renderText({
    partition <- "regular"
    email_options <- paste0(
      if (input$begin) "#SBATCH --mail-type=BEGIN\n" else "",
      if (input$end) "#SBATCH --mail-type=END\n" else "",
      if (input$fail) "#SBATCH --mail-type=FAIL\n" else ""
    )
    
    gpu_option <- if (input$gpu) "#SBATCH --gres=gpu:1\n" else ""
    
    total_time <- sprintf("%d-%02d:%02d:00",
                          input$days,
                          input$hours,
                          input$minutes)
    
    script <- paste0(
      "#!/bin/bash\n",
      "#SBATCH --job-name=", input$job_name, "\n",
      "#SBATCH --output=", input$job_name, ".out\n",
      "#SBATCH --error=", input$job_name, "_error.out\n",
      "#SBATCH --time=", total_time, "\n",
      "#SBATCH --partition=", partition, "\n",
      "#SBATCH --mem=", input$memory * 1024, "\n",
      "#SBATCH --cpus-per-task=", input$cpus, "\n",
      gpu_option,
      if (nzchar(input$email)) paste0("#SBATCH --mail-user=", input$email, "\n") else "",
      email_options,
      "\n",
      "# Write your code or script under this line\n",  # Added this line to clearly indicate where the commands for slum end and code starts
      input$commands
    )
    
    script
  })
  
  # Download handler for SLURM script
  output$download_script <- downloadHandler(
    filename = function() {
      paste(input$job_name, "_slurm_script.sh", sep = "")
    },
    content = function(file) {
      script <- paste0(
        "#!/bin/bash\n",
        "#SBATCH --job-name=", input$job_name, "\n",
        "#SBATCH --output=", input$job_name, ".out\n",
        "#SBATCH --error=", input$job_name, "_error.out\n",
        "#SBATCH --time=", sprintf("%d-%02d:%02d:00", input$days, input$hours, input$minutes), "\n",
        "#SBATCH --partition=regular\n",
        "#SBATCH --mem=", input$memory * 1024, "\n",
        "#SBATCH --cpus-per-task=", input$cpus, "\n",
        if (input$gpu) "#SBATCH --gres=gpu:1\n" else "",
        if (nzchar(input$email)) paste0("#SBATCH --mail-user=", input$email, "\n") else "",
        if (input$begin) "#SBATCH --mail-type=BEGIN\n" else "",
        if (input$end) "#SBATCH --mail-type=END\n" else "",
        if (input$fail) "#SBATCH --mail-type=FAIL\n" else "",
        "\n",
        "# Write your code or script under this line\n",  # Added this line here
        input$commands
      )
      
      writeLines(script, file)
    }
  )
  
  # Cheat Sheet Data
  cheat_sheet_data <- data.frame(
    Command = c(
      "sinfo -o \"%P %C %m %n %f\"",
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
      "Check available resources, cpu counts are allocated/idle/other/total.",
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
  
  output$cheat_sheet_table <- DT::renderDataTable({
    cheat_sheet_data
  })
}

# Run the application
shinyApp(ui = ui, server = server)