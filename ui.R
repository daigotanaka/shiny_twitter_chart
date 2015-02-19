library(shiny)

# See server.R for what this application does

# Define UI for application that draws a histogram
shinyUI(fluidPage(
    
    # Application title
    titlePanel("My Tweets in 2014: Impressions and Engagements"),
    
    # Sidebar with a slider input for the number of bins
    sidebarLayout(        
        sidebarPanel(
            checkboxGroupInput("languages",
                               "Languages",
                               c("English", "Japanese"),
                               selected=c("English", "Japanese")),
            sliderInput("month",
                        "Month",
                        min = 1,
                        max = 12,
                        value = 1),
            h3("Instruction"),
            p(paste("This application plots a bubble chart of the impressions (y-axis)",
                    "and engagements (size of bubble) of the tweets in 2014 by",
                    sep=" "), a("DaigoTanaka", href="http://www.twitter.com/DaigoTanaka")),
            p(paste("Impressions are the number of users who saw the tweet.",
                    "Engagements are the number of user's actions such as retweets, replies,",
                    "link clicks, profile clicks, and etc.")),
            p(paste("After the data load, use the checkboxes to turn on/off languages.",
                    "Use the slide bar to select a month to display the Tweets in the table.",
                    "It also calculates the average impressions of the selected month.",
                    sep=" ")),
            p("Please allow up to a minute to load the dataset on the right side!",
              style="color:red"),
            p("This application loads data from Amazon S3 storage. S3 storage should be",
              "very reliable, but if you encouter a problem of the right side panel not rendering",
              "please consider trying later.")
        ),
    
        mainPanel(
            textOutput("average"),
            plotOutput("tweetPlot"),
            dataTableOutput("tweetTable")
        )
    )
))