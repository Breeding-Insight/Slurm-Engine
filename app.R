library(shiny)
library(DT)

# Define UI for SLURM script generator with tabs
ui <- fluidPage(
  div(style = "font-size: 32px; font-weight: bold; text-align: center; margin-bottom: 20px;", "BI Slurm Engine"),
  
  tabsetPanel(
    tags$div(style = "text-align: center; margin-bottom: 20px;", tags$img(src = "logos.png", alt = "BI Logo", style = "max-width: 35%; height: auto;")),
    
    tabPanel(
      HTML("<b>Generate code to submit your job</b>"),
      sidebarLayout(
        sidebarPanel(
          textInput("job_name", "Job Name:", "my_job"),
          textInput("email", "Email address:", "@cornell.edu"),
          numericInput("memory", "Memory (GB):", 4, min = 1),
          numericInput("cpus", "Number of CPUs:", 1, min = 1),
          div(style = "display: flex; gap: 10px;", 
              numericInput("days", "Days:", 0, min = 0, width = "33%"),
              numericInput("hours", "Hours:", 1, min = 0, width = "33%"),
              numericInput("minutes", "Minutes:", 0, min = 0, width = "33%")),
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
    
    tabPanel(
      HTML("<b>Run Your Code Interactively</b>"),
      sidebarLayout(
        sidebarPanel(
          textInput("interactive_job_name", "Job Name:", "interactive_test"),
          textInput("interactive_email", "Email address:", "@cornell.edu"),
          numericInput("interactive_memory", "Memory (GB):", 40, min = 1),
          numericInput("interactive_cpus", "Number of CPUs:", 4, min = 1),
          div(style = "display: flex; gap: 10px;", 
              numericInput("interactive_days", "Days:", 0, min = 0, width = "33%"),
              numericInput("interactive_hours", "Hours:", 1, min = 0, width = "33%"),
              numericInput("interactive_minutes", "Minutes:", 0, min = 0, width = "33%")),
          checkboxInput("interactive_gpu", "Request GPU", FALSE)
        ),
        mainPanel(
          h4("Generated Interactive SLURM Command:"),
          verbatimTextOutput("interactive_command")
        )
      )
    ),
    
    tabPanel(
      HTML("<b>Cheat Sheet</b>"),
      titlePanel("Useful Commands"),
      mainPanel(
        DT::dataTableOutput("cheat_sheet_table")
      )
    )
  )
)

server <- function(input, output) {
  output$slurm_script <- renderText({
    job_name <- input$job_name
    email <- input$email
    memory <- input$memory
    cpus <- input$cpus
    time <- sprintf("%d-%02d:%02d:00", input$days, input$hours, input$minutes)
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
      "#SBATCH --time=", time, "\n",
      gpu, "\n",
      "\n", commands
    )
    return(script)
  })
  
  output$download_script <- downloadHandler(
    filename = function() {
      paste0(input$job_name, "_slurm.sh")
    },
    content = function(file) {
      writeLines(output$slurm_script(), file)
    }
  )
  
  output$interactive_command <- renderText({
    job_name <- input$interactive_job_name
    email <- input$interactive_email
    memory <- input$interactive_memory
    cpus <- input$interactive_cpus
    time <- sprintf("%d-%02d:%02d:00", input$interactive_days, input$interactive_hours, input$interactive_minutes)
    gpu <- ifelse(input$interactive_gpu, "--gres=gpu:1", "")
    
    command <- paste0(
      "salloc --job-name=", job_name, " ",
      "--mem=", memory, "G ",
      "--cpus-per-task=", cpus, " ",
      "--time=", time, " ",
      gpu, " ",
      "--mail-type=ALL ",
      "--mail-user=", email
    )
    return(command)
  })
  
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
