library(readr)
library(dplyr) # ignore the warning
library(tidyr)
library(ggplot2)

lables <- c("name","accuracy","PC","performance","SS","S","A")

Player1 <- read_csv("../Python code/new_player_data_old.csv",col_names = lables) %>%
  select(performance,PC,accuracy,SS,S,A) %>% # I don't need player names for this analysis. 
  mutate(group = "old")

lables2 <- c("name","performance","accuracy","PC","SS","S","A")

Player2 <- read_csv("../Python code/new_player_data.csv",col_names = lables2) %>%
  select(performance,PC,accuracy,SS,S,A) %>% # I don't need player names for this analysis. 
  mutate(group = "new")

Player <- rbind(Player1,Player2)


# for some reason Player isn't sorted by performance yet. 


# function to help with repeated code
is_in_range <- function(obj) {
  between(obj,mean(obj)-4*sd(obj),mean(obj)+4*sd(obj))
}
filtered_data <- Player %>%
  filter(
    is_in_range(PC),
    is_in_range(S),
    is_in_range(A),
    is_in_range(SS)
  ) 

#useful for some plotting
filtered_data_means <-filtered_data %>%
  group_by(group) %>%
  summarise(mean_pf = mean(performance),
            mean_pc = mean(PC),
            mean_s = mean(S),
            mean_a = mean(A),
            mean_ss = mean(SS)) %>%
  mutate(
    group = ifelse(group == 'new','new mean','old mean')
  )

#View(filtered_data_means)

#basic histogram. (Good). We have the mean lines included to see the differences in old and new data. 
ggplot(data = filtered_data) + 
  geom_histogram(mapping = aes(x= performance, fill = group), bins = 100) +
  geom_vline(data = filtered_data_means, mapping = aes(xintercept = mean_pf[1], color = 'new mean'), size = 1.25, linetype="twodash") +
  geom_vline(data = filtered_data_means, mapping = aes(xintercept = mean_pf[2], color = 'old mean'), size = 1.25, linetype="twodash") +
  scale_colour_manual('Lines',values = c("red","blue")) +
  theme_bw()


# mutating tibble filtered_data_means for the upcoming graph. For faceting purposes
filtered_data_means_2 <- filtered_data_means %>%
  gather(key = key, value = value, mean_s, mean_a) %>%
  mutate(key = ifelse(key == "mean_s","S","A")) 

#(Very good) Faceted differences between past and new data (S and A comparisons only)
fac_histo <- filtered_data %>%
  gather(key = key, value = value, -performance, -PC, -accuracy, -group, -SS) %>%
  ggplot() +
  geom_histogram(mapping = aes(x = value, fill = group), bins = 100) +
  geom_vline(data = filtered_data_means_2, mapping = aes(xintercept = value, color = group), size = 1.25, linetype="twodash") +
  scale_colour_manual('Lines',values = c("red","blue")) +
  theme_bw()

fac_histo + facet_grid(key ~ .)



# PC vs performance (NOT GOOD). Poor visualizations, scatter plot
ggplot(data = filtered_data) +
  geom_point(mapping = aes(x = PC, y = performance, color = group),alpha = 1/5) +
  geom_hline(data = filtered_data_means, mapping = aes(yintercept = mean_pf[1], color = 'new mean'), size = 1.25, linetype="twodash") +
  geom_hline(data = filtered_data_means, mapping = aes(yintercept = mean_pf[2], color = 'old mean'), size = 1.25, linetype="twodash") +
  geom_vline(data = filtered_data_means, mapping = aes(xintercept = mean_pc[1], color = 'new mean'), size = 1.25, linetype="twodash") +
  geom_vline(data = filtered_data_means, mapping = aes(xintercept = mean_pc[2], color = 'old mean'), size = 1.25, linetype="twodash") +
  scale_colour_manual('Legneds',values = c("#F8766D","red", "#00BFC4", "blue")) +
  theme_bw()

# (Okay enough for a plot). Interesting because faceted heat maps. 
ggplot(filtered_data) +
  geom_bin2d(aes(PC,performance)) +
  scale_fill_gradient2(high = "darkblue") +
  facet_grid(. ~ group) +
  theme_bw()

# (Questionable). I think we already pointed out how S/A differs. 
filtered_data %>%
  gather(key = key, value = value, S, A) %>%
  ggplot() +
  geom_bin2d(aes(value,performance)) +
  scale_fill_gradient2(high = "darkblue") +
  facet_grid(key ~ group) +
  theme_bw()

# performance to PC
# performance to aux
# PC to aux









matrix_filter <- cor(filtered_data %>% select(-accuracy, -group))
matrix_all <- cor(Player %>% select(-accuracy, -group))
matrix_old <- cor(Player %>% filter(group == 'old') %>% select(-accuracy, -group))
matrix_new <- cor(Player %>% filter(group == 'new') %>% select(-accuracy, -group))
row_labels <- c('all','filtered', 'new', 'old')
giga_matrix <- matrix(c(round(matrix_all[,'performance'],2),
       round(matrix_filter[,'performance'],2),
       round(matrix_new[,'performance'],2),
       round(matrix_old[,'performance'],2)),nrow = 4, byrow = TRUE)
rownames(giga_matrix) <- row_labels
colnames(giga_matrix) <- colnames(matrix_all)
giga_matrix
# There's little difference between old and new correlational values. at most a difference of 0.2
# It's super interesting that cor(performance,A) increases when we combine old and new datasets. We jump
# from an average of .13 to .245 value. Furthermore, cor(performance,S) decreases dramatically. That's so strange.
# This is probably a result of the chronological properties of the old and new data sets. There was a time where
# 10,000pp was very difficult to achieve. Now a days, beatmaps offer higher potential for performance gain. In particular,
# I recall a time where the player formerly known as hvick22 obtained a >500pp beatmap. At the time, this was an
# amzing feat. Now, the current rank 1 obtained a >1000pp in 2019. This was about 2 years after the >500p achievement. 
# Clearly, what we think is possible/obtainable is rising.

# suggest a correctional term? Or just analyze models separetly. 



## Linear Modeling =========================

model1 <- lm(performance ~ PC, filtered_data)

a_1 <- model1$coefficients['PC']
b_2 <- model1$coefficients['(Intercept)']


# (Good) If we want to have a basic linear model only using play_count as a variable, we get the graph below
ggplot(filtered_data) + 
  geom_point(aes(x = PC, y = performance), alpha = 1/80) +
  geom_abline(aes(slope = a_1, intercept = b_2, color = "black"), size = 2, show.legend = TRUE) +
  geom_abline(aes(slope = 0, intercept = mean(Player$performance), color = "red"), size = 2, show.legend = TRUE) +
  scale_colour_manual(name = c('Lines'),
                      labels = c("Regression", "Base"), 
                      values = c("black", "red")) +
  theme_bw()
# this is basically a trend line. F(PC) = 0.0167 * PC + 5792
# Discussion. The 5792 constant isn't ideal since. It acts like a lower bound where 0 is the true lower bound
# for performance. So, assuming you're in the top 10,000 ranking (i.e. performance >= 6000)



# (Excellent) other linear model with all variables using the filtered_data
model2_new <- lm(performance ~ PC + S + A + SS, data = filtered_data %>% filter(group == 'new'))
model2_old <- lm(performance ~ PC + S + A + SS, data = filtered_data %>% filter(group == 'old'))

a_new <- model2_new$coefficients['PC']
b_new <- model2_new$coefficients['S']
c_new <- model2_new$coefficients['A']
d_new <- model2_new$coefficients['SS']
e_new <- model2_new$coefficients['(Intercept)']
a_old <- model2_old$coefficients['PC']
b_old <- model2_old$coefficients['S']
c_old <- model2_old$coefficients['A']
d_old <- model2_old$coefficients['SS']
e_old <- model2_old$coefficients['(Intercept)']

# mutating Player for the following graphs.
Player <- Player %>%
  mutate(
    lm_performance_old = a_old*PC + b_old*S +c_old*A + d_old*SS + e_old,
    lm_performance_new = a_new*PC + b_new*S +c_new*A + d_new*SS + e_new
  )


# (Really Good) Like above, we compare performance and lm_performance in regards to PC. 
ggplot(Player) +
  geom_point(aes(PC,performance, color = "Performance")) +
  geom_point(aes(PC,lm_performance_old, color = "Linear Model")) +
  scale_colour_manual("Dots", values = c("blue","black")) +
  theme_bw()

# (Really Good) faceting the above:
facet_point <- Player %>%
  gather(key = key, value = value, SS,S,A) %>% # key contains (PC,A,SS,S)
  ggplot() +
  geom_point(aes(value,performance, color = "Performance")) +
  geom_point(aes(value,lm_performance_old, color = "Linear Model")) +
  theme_bw()

# Now we facet the scatter plot (contained in variable facet_points). 
facet_point + facet_grid(key ~ .) +
  scale_colour_manual("Dots", values = c("blue","black"))
