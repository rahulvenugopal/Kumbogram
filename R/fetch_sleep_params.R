#' Calculate sleep micro architecture parameters
#'
#' @param hypnogram_file A character array with sleep stages
#' @param epoch_duration Duration of sleep epoch in seconds
#'
#' @return A data frame with 32 columns
#' @export
#'
#' @examples
#' sleep_data <- fetch_sleep_params(hypnogram_file = c('W' ,'W','N1','N2','N2','N3','R'),
#' epoch_duration = 30)
fetch_sleep_params<- function(hypnogram_file, epoch_duration) {

  start_of_stages <- data.frame(unclass(rle(hypnogram_file)))
  colnames(start_of_stages)[2] <- "values"

  # Creating a .csv sheet with all parameters
  sleep_data <- data.frame(Wake_duration=numeric(0),
                           N1_duration=numeric(0),
                           N2_duration=numeric(0),
                           N3_duration=numeric(0),
                           R_duration=numeric(0),
                           Wake_percentage=numeric(0),
                           N1_percentage=numeric(0),
                           N2_percentage=numeric(0),
                           N3_percentage=numeric(0),
                           R_percentage=numeric(0),
                           sleep_efficiency=numeric(0),
                           Wake_onset=numeric(0),
                           N1_onset=numeric(0),
                           N2_onset=numeric(0),
                           N3_onset=numeric(0),
                           R_onset=numeric(0),
                           TST=numeric(0),
                           W_longest_streak=numeric(0),
                           N1_longest_streak=numeric(0),
                           N2_longest_streak=numeric(0),
                           N3_longest_streak=numeric(0),
                           R_longest_streak=numeric(0),
                           W_mean_length_of_streak=numeric(0),
                           N1_mean_length_of_streak=numeric(0),
                           N2_mean_length_of_streak=numeric(0),
                           N3_mean_length_of_streak=numeric(0),
                           R_mean_length_of_streak=numeric(0),
                           W_median_length_of_streak=numeric(0),
                           N1_median_length_of_streak=numeric(0),
                           N2_median_length_of_streak=numeric(0),
                           N3_median_length_of_streak=numeric(0),
                           R_median_length_of_streak=numeric(0)
  )

  sleep_data[1,17] = (length(hypnogram_file)*epoch_duration)/60

  # Onset latency of stages
  stages_list <- c("W","N1","N2","N3","R")
  #onset = 0

  for (stages in 1:length(stages_list))  {
    sleep_data[1,stages+11] = ((match(stages_list[stages],hypnogram_file) - 1)*epoch_duration)/60
  }

  # Stage duration
  stage_durations <- as.data.frame((table(hypnogram_file)*epoch_duration)/60)

  for (stages in 1:length(stages_list)){
    sleep_data[1,stages] = (subset(stage_durations, hypnogram_file == stages_list[stages])$Freq[1])
  }

  # Sleep stage percentages
  stage_percentages <- data.frame(round(table(hypnogram_file)/length(hypnogram_file),2))

  for (stages in 1:length(stages_list)){
    sleep_data[1,stages+5] = (subset(stage_percentages, hypnogram_file == stages_list[stages])$Freq[1])
  }

  # Sleep efficiency
  sleep_data[1,11] <- (sum(subset(stage_durations, hypnogram_file != "W")$Freq ) / sleep_data[1,17])*100

  # Finding longest streak of each stage
  # Converting stages into factors
  start_of_stages$values <- as.factor(start_of_stages$values)

  # Ordering the streak lengths
  start_of_stages <- start_of_stages[order(start_of_stages$values, -start_of_stages$lengths),]

  # Removing duplicates from the sorted sub column
  longest_streaks <- start_of_stages[!duplicated(start_of_stages$values),]

  # Writing to main dataframe
  for (stages in 1:length(stages_list)){
    sleep_data[1,stages+17] = ((subset(longest_streaks,
                                       values == stages_list[stages])$lengths[1]) * epoch_duration)/60
  }

  mean_run_lengths_stages <- stats::aggregate(lengths ~ values, start_of_stages,mean)
  for (stages in 1:length(stages_list))  {
    sleep_data[1,stages+22] = (subset(mean_run_lengths_stages, values == stages_list[stages])$lengths[1] * epoch_duration)/60
  }

  median_run_lengths_stages <- stats::aggregate(lengths ~ values, start_of_stages,stats::median)
  for (stages in 1:length(stages_list))  {
    sleep_data[1,stages+27] = (subset(median_run_lengths_stages, values == stages_list[stages])$lengths[1] * epoch_duration)/60
  }

  return(sleep_data)
}
