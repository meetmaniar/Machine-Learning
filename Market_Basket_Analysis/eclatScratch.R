#Set and examine global options in R which may affect the computation
options(stringsAsFactors = FALSE)

ec_start_time <- Sys.time();
#set initial parameters
min_support <- 100

#Reading and preprocessing data
#read input data
input_file <- "Market_Basket_Optimisation.csv"
input_data <- readLines(input_file) # horizontal format
input_data <- data.frame(TID = 1:length(input_data), Items = input_data)

#transform from horizontal to vertical format
#first from horizontal to pairs format (table Items-TID pairs)
input_data_pairs_format <- lapply(1:nrow(input_data), function(i) {
  data.frame(TID = input_data$TID[i],
              ItemSet = strsplit(input_data$Items[i], ",")[[1]])
})
input_data_pairs_format <- do.call(rbind, input_data_pairs_format)
#Second from pairs format to horizontal format
input_data_vertical_format <- lapply(unique(input_data_pairs_format$ItemSet), function(item) {
  data.frame(ItemSet = item,
             TIDset = paste(input_data_pairs_format$TID[input_data_pairs_format$ItemSet==item], collapse=", "))
})
input_data_vertical_format <- do.call(rbind, input_data_vertical_format)

#rename table; it will be initial data for ECLAT algorithm
initial_data <- input_data_vertical_format
rm(input_data_pairs_format, input_data_vertical_format)

### Searching frequent itemsets using ECLAT algorithm
#create empty resulting table
all_frequent_itemsets <- data.frame(ItemSet = character(0), TIDset = character(0), support = numeric(0))

## k=1, Frequent 1-itemsets
k <- 1 # k value is not used directly
print(paste("Generating frequent-", k, " datasets..."))
#add all new possible itemsets (in this case - all items)
new_candidate_frequent_itemsets <- initial_data
#calculate support for new possible itemsets
new_candidate_frequent_itemsets$support <- sapply(new_candidate_frequent_itemsets$TIDset, function(x) length(strsplit(x, ",")[[1]]))
#leave only new itemsets with sufficient support
candidate_frequent_itemsets <- new_candidate_frequent_itemsets[new_candidate_frequent_itemsets$support >= min_support, ]
#add new itemsets to resulting table
all_frequent_itemsets <- rbind(all_frequent_itemsets, candidate_frequent_itemsets)

#if frequent itemsets on the first step were created, then we may continue for next k (otherwise we should stop)
if (nrow(candidate_frequent_itemsets) > 0) {
  
  ##repeat in a loop
  while (TRUE) {
    
    #Frequent k-itemsets
    k <- k+1 # increment k, it just indicates that we move to new step
    print(paste("Generating frequent-", k, " datasets..."))
    
    #create  empty table for new possible itemsets
    new_candidate_frequent_itemsets <- data.frame(ItemSet = character(0), TIDset = character(0))
    
    #add new possible candidate datasets as {}-conditional databases
    #do for all itemsets from previous step (for previous k)
    for (i in 1:length(candidate_frequent_itemsets$ItemSet)) {
      #get all items of itemset as vector
      candidate_items <- strsplit(candidate_frequent_itemsets$ItemSet[i], ",")[[1]]
      
      #do for all initial items
      for (j in 1:length(initial_data$ItemSet)) {
        #get initial item which will be added
        new_item <- initial_data$ItemSet[j]
        
        #check if this item already in itemset, if yes then do nothing (move to next item)
        if (!(new_item %in% candidate_items)) {
          #if no, add this item to itemset (sorting cause we may have duplicated itemsets, and will have to remove them)
          new_itemset <- sort(c(candidate_items, new_item))
          #get TID set for this new itemset
          new_tidset <- intersect(strsplit(candidate_frequent_itemsets$TIDset[i], ",")[[1]], strsplit(initial_data$TIDset[j], ",")[[1]])
          #add new itemset to new possible itemsets
          new_candidate_frequent_itemsets <- rbind(new_candidate_frequent_itemsets, 
                                                   data.frame(ItemSet = paste(new_itemset, collapse = ","), 
                                                              TIDset = paste(new_tidset, collapse = ",")))
        }
      }
    }
    
    #remove duplicates from new possible itemsets
    new_candidate_frequent_itemsets <- unique(new_candidate_frequent_itemsets)
    #calculate support for new possible itemsets
    new_candidate_frequent_itemsets$support <- sapply(new_candidate_frequent_itemsets$TIDset, 
                                                      function(x) length(strsplit(x, ",")[[1]]))
    #leave only new itemsets with sufficient support
    candidate_frequent_itemsets <- new_candidate_frequent_itemsets[new_candidate_frequent_itemsets$support >= min_support, ]
    
    #stop algorith if no new itemsets found
    if (nrow(candidate_frequent_itemsets) == 0) {
      break
    }
    
    #add new itemsets to resulting table
    all_frequent_itemsets <- rbind(all_frequent_itemsets, candidate_frequent_itemsets)
  }
}

print("Completed")

#save resulting itemsets to file
writeLines(paste(all_frequent_itemsets$support, " " ,all_frequent_itemsets$ItemSet ), "Market_Basket_Optimisation_Result.csv")
ec_end_time <- Sys.time()
print(paste("Total Duration" , ec_end_time - ec_start_time))
View(all_frequent_itemsets)

#Graph Plotting
library(plotly)
N <- 15
all_frequent_itemsets$count <- all_frequent_itemsets$support
all_frequent_itemsets <- all_frequent_itemsets[order(-all_frequent_itemsets$count), ]
all_frequent_itemsets$support <- all_frequent_itemsets$count/nrow(input_data)
all_frequent_itemsets$support_label <- round(all_frequent_itemsets$support, 3)

plot_ly(all_frequent_itemsets[1:N, ], x = ~ItemSet, y = ~count,
        type = "bar", hoverinfo="none",
        marker = list(color = '#CEDCEC', line = list(color = '#326299', width = 1.5))) %>%
 layout(title = NULL,
         xaxis = list(title = "", showgrid = FALSE, categoryarray = ~ItemSet, categoryorder = "array", tickfont = list(size = 10)),
         yaxis = list(title = "", showline = FALSE, showgrid = FALSE, showticklabels = FALSE),
         margin = list(l = 60, t = 20, b = 150, r = 100)) %>%
  add_annotations(x = ~ItemSet, y = ~count, text = ~count, xanchor = 'center', yanchor = 'bottom', showarrow = FALSE) %>%
  add_annotations(x = ~ItemSet, y = ~count/2, text = ~support_label, xanchor = 'center', yanchor = 'center', showarrow = FALSE)

#Graph Plotting for Eclat Library algorithm
# library(plotly)
# N <- 15
# eclat_basket <- eclat_basket[order(-eclat_basket$count), ]
# eclat_basket$support_label <- round(eclat_basket$support, 3)
# 
# plot_ly(eclat_basket[1:N, ], x = ~items, y = ~count,
#         type = "bar", hoverinfo="none",
#         marker = list(color = '#CEDCEC',
#                       line = list(color = '#326299',
#                                   width = 1.5))) %>%
#   layout(title = NULL,
#          xaxis = list(title = "", showgrid = FALSE, categoryarray = ~items, categoryorder = "array", tickfont = list(size = 10)),
#          yaxis = list(title = "", showline = FALSE, showgrid = FALSE, showticklabels = FALSE),
#          margin = list(l = 60, t = 20, b = 150, r = 100)) %>%
#   add_annotations(x = ~items, y = ~count, text = ~count,
#                   xanchor = 'center', yanchor = 'bottom', showarrow = FALSE) %>%
#   add_annotations(x = ~items, y = ~count/2, text = ~support_label,
#                   xanchor = 'center', yanchor = 'center', showarrow = FALSE)