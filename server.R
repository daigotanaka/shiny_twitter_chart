library(shiny)
library(RCurl)
library(ggplot2)

# This application plots a bubble chart of Tweet impressions (y) and engagements
# (size). Select a month to show the tweets

shinyServer(function(input, output) {
    
    data <- NULL
    
    # Run just once at the initialization
    getData <- function() {
        if (!is.null(data)) return (data)
        # Load Tweets with meta data
        message("Loading data...")
        url <- getURL(
            "https://s3-us-west-1.amazonaws.com/daigotanaka-data/daigotanaka-tweets-2014.csv",
            .encoding="UTF-8")
        tweets <- read.csv(text=url, head=TRUE, stringsAsFactors=FALSE)
        
        # Load CSV
        url <- getURL(
            "https://s3-us-west-1.amazonaws.com/daigotanaka-data/tweet-activity-metrics-daigotanaka-2014.csv",
            .encoding="UTF-8")
        metrics <- read.csv(text=url, head=TRUE, stringsAsFactors=FALSE)
        
        # Change the column name from Tweet.id to id
        col_names <- names(metrics)
        col_names[1] <- "id"
        colnames(metrics) <- col_names
        
        # Remove outliers and an error entry
        metrics <- metrics[is.numeric(metrics$impressions) & metrics$impressions > 0 & metrics$id != 513495667927711744,]
        merged <- merge(x=tweets, y=metrics, by="id", all=F)
        merged$date <- as.POSIXlt(strptime(as.character(merged$time), "%Y-%m-%d %H:%M %z", tz="UTC"))
        data <<- subset(merged, 1 <= merged$impressions & merged$impressions <= 400)
        
        message("done")
        
        return (data)
    }
    
    output$tweetPlot <- renderPlot({
        data <- getData()
        lang <- tolower(substr(input$languages, 1, 2))
        month <- input$month
        start <- as.POSIXlt(strptime(sprintf("2014-%02d-01", month), "%Y-%m-%d", tz="UTC"))
        end <- as.POSIXlt(strptime(sprintf("2014-%02d-28", month), "%Y-%m-%d", tz="UTC"))
        print(ggplot() 
              + geom_rect(data=data.frame(xmin=start, xmax=end, ymin=0, ymax=Inf),
                          aes(xmin=xmin, xmax=xmax, ymin=ymin,ymax=ymax), fill="gray")
              + geom_point(data=data[data$lang %in% lang,], aes(x=date, y=impressions, col=lang, size=engagements))
        )
    })

    output$tweetTable <- renderDataTable({
        data <- getData()
        month <- input$month
        # Display date, text, impressions, and engagements
        display <- data[data$date$mon == month - 1, c(45, 3, 9, 10)]
        display <- display[order(-display$impressions),]
        data.frame(date=display$date,
                   text=display$text,
                   impressions=display$impressions,
                   engagements=display$engagements)
    }, options = list(pageLength = 10))
    
    output$average <- renderText({
        month <- input$month
        months <- c("January", "February", "March", "April", "May", "June",
                  "July", "August", "September", "Octorber", "November", "December")
        
        avgImpressions = mean(data[data$date$mon == month - 1,]$impressions)
        sprintf("Average impressions was %.2f in the month of %s",
                avgImpressions, months[month])
    })
})
