# importing libraries -------------------
library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)

# importing dataset -------------------
Player <- read_csv("Player.csv",col_names = FALSE)
lables <- c("player_id","name","rank","performance","accuracy","play_count","SS","S","A")
colnames(Player) <- lables
#View(Player)

# dataset cleaning -------------------
# simplify Player set
miniPlayer <- Player %>%
  select(rank,performance, accuracy,play_count,SS,S,A)

ggplot(miniPlayer) +
  geom_point(aes(x=rank,y=log(play_count)))

# new tibble for covariance calculations. (not good)
centered_mini_player <- miniPlayer %>%
  mutate(
    play_count = (play_count-mean(play_count))/sqrt(var(play_count)),
    S = (S-mean(S))/sqrt(var(S)), # centering,
    SS = (SS-mean(SS))/sqrt(var(SS)), # centering
    A = (A - mean(A))/sqrt(var(A)), # centering
    accuracy = (accuracy - mean(accuracy))/sd(accuracy),
    performance = (performance - mean(performance))/sd(accuracy)
  ) 

# viewing and filtering centered data -------------------

#warning:Removed 5060 rows containing non-finite values (stat_boxplot). 
centered_mini_player %>%
  gather(key = key, value = value, -rank) %>%
  ggplot(aes(x = key, y = value)) +
  geom_boxplot() +
  ylim(-5,5)

# based on above plot, decide what to filter out

# x < 4.5(std)+mean
filtered_data <- miniPlayer %>%
  mutate(
    S = ifelse(S<(4.5*sd(S)+mean(S)), S, NA),
    SS = ifelse(SS<(4.5*sd(SS)+mean(SS)), SS, NA),
    A = ifelse(A<(4.5*sd(A)+mean(A)), A, NA),
    play_count= ifelse(play_count<(4.5*sd(play_count)+mean(play_count)), play_count, NA),
    accuracy= ifelse(accuracy>(-4.5*sd(accuracy)+mean(accuracy)), accuracy, NA)
  ) %>%
  filter(is.na(S)==FALSE,is.na(SS)==FALSE,is.na(A)==FALSE,is.na(play_count)==FALSE,is.na(accuracy)==FALSE)

#exeprimental version. Being very liberal with taking out outliers
filtered_data2 <- miniPlayer %>%
  mutate(
    performance = (performance-mean(performance))/sd(performance),
    S = ifelse(S<(1.5*sd(S)+mean(S)), S, NA),
    SS = ifelse(SS<(0.5*sd(SS)+mean(SS)), SS, NA),
    A = ifelse(A<(2.2*sd(A)+mean(A)), A, NA),
    play_count= ifelse(play_count<(2.25*sd(play_count)+mean(play_count)), play_count, NA),
    accuracy= ifelse(accuracy>(-1.75*sd(accuracy)+mean(accuracy)), accuracy, NA)
  ) %>%
  filter(is.na(S)==FALSE,is.na(SS)==FALSE,is.na(A)==FALSE,is.na(play_count)==FALSE,is.na(accuracy)==FALSE)


centered_filtered_data <- filtered_data %>%
  mutate(
    performance = (performance - mean(performance))/sd(performance),
    S = (S-mean(S))/sd(S),
    SS = (SS-mean(SS))/sd(SS), 
    A = (A - mean(A))/sd(A),
    accuracy = (accuracy - mean(accuracy))/sd(accuracy),
    play_count = (play_count-mean(play_count))/sd(play_count)
  ) 

# get sample correlational matrix -------------------
prf_vec <- centered_filtered_data$performance
acc_vec <- centered_filtered_data$accuracy
s_vec  <- centered_filtered_data$S
ss_vec <- centered_filtered_data$SS
a_vec <- centered_filtered_data$A
pc_vec <- centered_filtered_data$play_count

M <- cbind(prf_vec,pc_vec,acc_vec,ss_vec,s_vec,a_vec)
CM <- cor(M)
CM
# eigendecompose the correlational matrix -------------------
#ECM <- eigen(CM,symmetric = TRUE)
#ECM
#lambda1 <- ECM[[1]][[1]]
#vector1 <- ECM[[2]][,1]
#lambda2 <- ECM[[1]][[2]]
#vector2 <- ECM[[2]][,2]

# plotting results -------------------
# 1st correlation, q = 0.50574356
# 1st experimental correlation, q = 0.6016588
ggplot(centered_filtered_data) +
  geom_point(aes(x = S, y = SS),alpha = 1/30) +
  geom_abline(slope = CM['s_vec','ss_vec'],color = "red")

# 3rd correlation, q = 0.38941110
# 2nd experimental correlation, q = 0.42957095
ggplot(centered_filtered_data) +
  geom_point(aes(x = S, y = A),alpha = 1/30) +
  geom_abline(slope = CM['s_vec','a_vec'],color = "red") 

# 2nd correlation, q = 0.4391454
# 3rd experimental correlation, q = 0.3856870
ggplot(centered_filtered_data) +
  geom_point(aes(x = S, y = play_count),alpha = 1/30) +
  geom_abline(slope = CM['s_vec','pc_vec'],color = "red") 


# 1st experimental correlation in regards to performance, q = 0.3379438
ggplot(centered_filtered_data) +
  geom_point(aes(x = play_count, y = performance),alpha = 1/30) +
  geom_abline(slope = CM['pc_vec','prf_vec'],color = "red") +
  geom_abline()

# 2nd experimental correlation in regards to performance, q = 0.1608370
ggplot(centered_filtered_data) +
  geom_point(aes(x = S, y = performance),alpha = 1/30) +
  geom_abline(slope = CM['s_vec','prf_vec'],color = "red") +
  geom_abline()

# last experimental correlation in regards to performance, q = -0.05939164
ggplot(centered_filtered_data) +
  geom_point(aes(x = accuracy, y = performance),alpha = 1/30) +
  geom_abline(slope = CM['acc_vec','prf_vec'],color = "red") +
  geom_abline()

# last experimental correlation, q = 0.03081100
ggplot(centered_filtered_data) +
  geom_point(aes(x = accuracy, y = play_count),alpha = 1/10) +
  geom_abline(slope = CM['acc_vec','pc_vec'],color = "red") 

# smallest correlation, q = 0.07447896
ggplot(centered_filtered_data) +
  geom_point(aes(x = A, y = SS),alpha = 1/10) +
  geom_abline(slope = CM['a_vec','ss_vec'],color = "red") 


# more exploratory analysis -----------------------------
miniPlayer %>%
  select(rank,play_count,SS,S,A) %>%
  mutate(map_play_ratio = play_count/(SS+S+A)) %>%
  ggplot(mapping = aes(x = map_play_ratio)) +
  geom_histogram(bins = 80) +
  xlim(0,300)
  #geom_boxplot(mapping = aes(group = cut_width(map_play_ratio,500)),na.rm = TRUE)

# experimental plots ------------------------------------

my_pmf <- function(min_perf,min_plays,min_s_count){
  top <- miniPlayer %>%
    filter(play_count <= min_plays, performance >= min_perf, S <= min_s_count) %>%
    count()
  
  bottom <- miniPlayer %>%
    filter(play_count <= min_plays, S <= min_s_count) %>%
    count()
  
  top/bottom
}
topPP <- 10080
brunopp <- 3568
brunoCount <- 35515
brunoSS <- 30+45
brunoS <- 158 + 989
brunoA <- 274
my_pmf(topPP,1000*brunoCount,100*brunoS)


ggplot(miniPlayer, aes(x = play_count))+stat_ecdf()

ggplot(centered_filtered_data) +
  #stat_ecdf(aes(x=performance), color = "blue") +
  stat_ecdf(aes(x=play_count), color = "red") +
  #stat_ecdf(aes(x=S), color = "gold") +
  xlim(-5,5)

ggplot(centered_filtered_data, aes(x = play_count))+stat_ecdf()



d <- density(miniPlayer$play_count)
plot(d)

ggplot(centered_filtered_data) +
#  geom_histogram(aes(x= play_count-min(play_count)),bins = 40, color = "blue")+
#  geom_histogram(aes(x= play_count-min(play_count)),bins = 80, color = "red")+
#  geom_histogram(aes(x= play_count-min(play_count)),bins = 120, color = "green")+
#  geom_histogram(aes(x= play_count-min(play_count)),bins = 160, color = "gold")+
  geom_freqpoly(aes(x= play_count-min(play_count)),bins = 40, color = "blue")+
  geom_freqpoly(aes(x= play_count-min(play_count)),bins = 80, color = "red")+
  geom_freqpoly(aes(x= play_count-min(play_count)),bins = 120, color = "green")+
  geom_freqpoly(aes(x= play_count-min(play_count)),bins = 160, color = "gold")

ggplot(centered_filtered_data) +
  #  geom_histogram(aes(x= S-min(S)),bins = 40, color = "blue")+
  #  geom_histogram(aes(x= S-min(S)),bins = 80, color = "red")+
  #  geom_histogram(aes(x= S-min(S)),bins = 120, color = "green")+
  #  geom_histogram(aes(x= S-min(S)),bins = 160, color = "gold")+
  geom_freqpoly(aes(x= S-min(S)),bins = 40, color = "blue")+
  geom_freqpoly(aes(x= S-min(S)),bins = 80, color = "red")+
  geom_freqpoly(aes(x= S-min(S)),bins = 120, color = "green")+
  geom_freqpoly(aes(x= S-min(S)),bins = 160, color = "gold")

ggplot(centered_filtered_data) +
  #  geom_histogram(aes(x= performance),bins = 40, color = "blue")+
  #  geom_histogram(aes(x= performance),bins = 80, color = "red")+
  #  geom_histogram(aes(x= performance),bins = 120, color = "green")+
  #  geom_histogram(aes(x= performance),bins = 160, color = "gold")+
  geom_freqpoly(aes(x= performance),bins = 20, color = "blue")+
  geom_freqpoly(aes(x= performance),bins = 30, color = "red")+
  geom_freqpoly(aes(x= performance),bins = 40, color = "green")+
  geom_freqpoly(aes(x= performance),bins = 50, color = "gold")

# Create the function.
getmode <- function(v) {
  uniqv <- unique(v)
  uniqv[which.max(tabulate(match(v, uniqv)))]
}

plays <- centered_filtered_data$play_count
my_mode <- getmode(plays)
my_var <- var(plays)
my_mean <- mean(plays)

