library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)

# importing dataset -------------------
Player <- read_csv("Player2018.csv",col_names = FALSE)
lables <- c("player_id","name","rank","performance","accuracy","play_count","SS","S","A")
colnames(Player) <- lables
#View(Player)

# dataset cleaning -------------------
# simplify Player set
miniPlayer <- Player %>%
  select(rank,performance, accuracy,play_count,SS,S,A)

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
  ylim(-6,6)

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
    A = ifelse(A<(2.5*sd(A)+mean(A)), A, NA),
    play_count= ifelse(play_count<(2.5*sd(play_count)+mean(play_count)), play_count, NA),
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
# (2018) 1st correlation, q = 0.51713362
# (2018) 1st experimental correlation, q = 0.56871114
ggplot(centered_filtered_data) +
  geom_point(aes(x = S, y = SS),alpha = 1/30) +
  geom_abline(slope = CM['s_vec','ss_vec'],color = "red")

# (2018) 4th correlation, q = 0.26883330
# (2018) 2nd experimental correlation, q = 0.40300855
ggplot(centered_filtered_data) +
  geom_point(aes(x = S, y = A),alpha = 1/30) +
  geom_abline(slope = CM['s_vec','a_vec'],color = "red") 

# 2nd correlation, q = 0.43639479
# 3rd experimental correlation, q = 0.39268766
ggplot(centered_filtered_data) +
  geom_point(aes(x = S, y = play_count),alpha = 1/30) +
  geom_abline(slope = CM['s_vec','pc_vec'],color = "red") 

# correlation unfiltered
# (s,ss) 0.51713362
# (s,pc) 0.43639479
# (a,pc) 0.27743142
# (s,a) 0.26883330
# correlation filtered
# (s,ss) 0.56871114
# (s,a) 0.40300855
# (s,pc) 0.39268766
# (a,pc) 0.32892704
# (acc,pc) 0.02124249
# 1st experimental correlation in regards to performance, q = 0.25248915
ggplot(centered_filtered_data) +
  geom_point(aes(x = play_count, y = performance),alpha = 1/30) +
  geom_abline(slope = CM['pc_vec','prf_vec'],color = "red") +
  geom_abline()

# 2nd experimental correlation in regards to performance, q = 0.09571804
# barely any better than S
ggplot(centered_filtered_data) +
  geom_point(aes(x = S, y = performance),alpha = 1/30) +
  geom_abline(slope = CM['s_vec','prf_vec'],color = "red") +
  geom_abline()

# last experimental correlation in regards to performance, q = -0.04166413
ggplot(centered_filtered_data) +
  geom_point(aes(x = accuracy, y = performance),alpha = 1/30) +
  geom_abline(slope = CM['acc_vec','prf_vec'],color = "red") +
  geom_abline()

# last experimental correlation, q = 0.02124249
ggplot(centered_filtered_data) +
  geom_point(aes(x = accuracy, y = play_count),alpha = 1/10) +
  geom_abline(slope = CM['acc_vec','pc_vec'],color = "red") 

# smallest correlation, q = 0.07447896
ggplot(centered_filtered_data) +
  geom_point(aes(x = A, y = SS),alpha = 1/10) +
  geom_abline(slope = CM['a_vec','ss_vec'],color = "red") 


# experimental plots ------------------------------------

miniPlayer %>%
  mutate(map_play_ratio = (SS+S+A)/play_count) %>%
  ggplot(aes(x=rank,y=map_play_ratio)) +
  geom_point()
  
