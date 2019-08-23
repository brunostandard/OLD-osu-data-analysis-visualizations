library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)

Player <- read_csv("Player.csv",col_names = FALSE)
lables <- c("player_id","name","rank","performance","accuracy","play_count","SS","S","A")
colnames(Player) <- lables
head(Player)
#View(Player)

cor(Player$SS,Player$S)
#[1] 0.5118301
cor(Player$S,Player$A)
#[1] 0.4184849


# simplify Player set
miniPlayer <- Player %>%
  select(rank,play_count,SS,S,A)

# new tibble for covariance calculations. (not good)
cenetered_mini_player <- Player %>%
  mutate(
    S = (S-mean(S))/sqrt(var(S)), # centering,
    SS = (SS-mean(SS))/sqrt(var(SS)), # centering
    A = (A - mean(A))/sqrt(var(A)) # centering
  ) 

View(cenetered_mini_player)

# correlation didn't work out
cor_SS_S <- cor(cenetered_mini_player$SS,cenetered_mini_player$S)
cor_SS_S

# generate a psuedo heat map for SS vs S and S vs A. (Interesting)
# I like to see proportions. (needs covariance)
cenetered_mini_player %>%
  ggplot() + 
  geom_point(mapping = aes(x = SS, y = S), alpha = 1/50) +
  geom_abline(slope = cor_SS_S) +
  geom_abline(slope = 1)

# generate a psuedo heat map for S vs A. (Interesting)
# I like to see proportions. (needs covariance)
miniPlayer %>%
  filter(between(S,0,10000),between(A,0,10000)) %>%
  ggplot() + 
  geom_point(mapping = aes(x = S, y = A), alpha = 0.5) +
  geom_abline(slope = 1)



# generate multiple boxplot of rank and play count (good)
miniPlayer %>%
  filter(play_count <3e+05) %>%
  ggplot(mapping = aes(x = rank, y = play_count)) +
  geom_boxplot(mapping = aes(group = cut_width(rank,350)),na.rm = TRUE)

# generate boxplots for SS,S,A distribution (doesn't look good)
miniPlayer %>%
  gather(key=key,value=value,-rank,-play_count) %>%
  mutate(
    value = ifelse(value > 10000, NA,value)
  ) %>%
  ggplot(mapping = aes(x = rank, y = value, color = key)) +
  geom_boxplot(na.rm = TRUE)  

#analyzing the distribution of SS, S, and A values (count) with boxplots
#there are a lot of outliers (not good)
Player %>%
  select(rank,play_count,SS,S,A) %>%
  gather(key = key, value = value, -rank,-play_count) %>%
  mutate(
    value = ifelse(value>3500, NA,value)
  ) %>%
  ggplot(mapping = aes(x = key, y = value)) +
  geom_boxplot(na.rm = TRUE)

# histogram for play_count
ggplot(data = miniPlayer) +
  geom_histogram(mapping = aes(x = play_count),bins = 60, fill = "pink", color = "black", alpha = 0.6)

# boxplot of SS (very good)
miniPlayer %>%
  filter(SS < 2000) %>%
  ggplot(mapping = aes(x = rank, y = SS)) +
  geom_boxplot(mapping = aes(group = cut_width(rank,350)))

# boxplot of S (very good)
miniPlayer %>%
  filter(S < 7500) %>%
  ggplot(mapping = aes(x = rank, y = S)) +
  geom_boxplot(mapping = aes(group = cut_width(rank,350)))

# boxplot of A (very good)
miniPlayer %>%
  filter(A < 5000) %>%
  ggplot(mapping = aes(x = rank, y = A)) +
  geom_boxplot(mapping = aes(group = cut_width(rank,350)))

# histogram of SS
miniPlayer %>%
  filter(SS < 2000) %>%
  ggplot(mapping = aes(x = SS)) +
  geom_histogram(bins = 75, fill = "white", color = "black", alpha = 1)

# histogram of S
miniPlayer %>%
  filter(S < 7500) %>%
  ggplot(mapping = aes(x = S)) +
  geom_histogram(bins = 75, fill = "gold", color = "black", alpha = 0.6)

# histogram of A
miniPlayer %>%
  filter(A < 5000) %>%
  ggplot(mapping = aes(x = A)) +
  geom_histogram(bins = 75, fill = "darkseagreen1", color = "black", alpha = 1)

# histograms of S and A (very good)
miniPlayer %>%
  filter(S < 10000, A < 10000) %>%
  gather(key=key,value=value, -SS, -rank,-play_count) %>%
  ggplot() +
  geom_histogram(mapping = aes(x = value, fill = key), bins = 90, alpha = 0.75)


#geom_point(alpha = 0.1) +
#geom_smooth()


head(Player)

Player2 <- Player %>%
  gather(key = "key", value = "value", -player_id, -name,-rank,-performance,-accuracy,-play_count)

#density break down of map count (SS,S,A) side by side
Player2 %>%
  mutate(value = ifelse(value > 4000,NA,value)) %>%
  ggplot(mapping = aes(x = value, y = ..density.., color = key)) +
    geom_freqpoly(na.rm = TRUE,binwidth = 50,linewidth = 2.0) 

#boxplot of keys and values. 
Player2 %>%
  mutate(value = ifelse(value > 2800,NA,value)) %>%
  ggplot(mapping = aes(x = reorder(key,value,FUN = median), y = value)) +
  geom_boxplot(na.rm = TRUE) 
# this indicates that around >2500 we have outliers (from the median)

Player %>%
  mutate(S = ifelse(S > 14000,NA,S),A = ifelse(A > 7000,NA,A)) %>%
  ggplot(mapping = aes(x = S, y = A)) +
  geom_bin2d() +
  geom_abline() 


ggplot(data = Player2, mapping = aes(x = rank, y = play_count)) +
  geom_point(alpha = 0.1) +
  geom_smooth()



#transforming
head(Player2)
PLayer3 <- Player2 %>%
  group_by(player_id,name,rank) %>%
  gather(key = 'key', value = "value", -player_id, -name,-rank,-performance,-accuracy,-play_count)

head(PLayer3)

ggplot(data = PLayer3) +
  geom_freqpoly(mapping = aes(x = value, class = key, color = key),binwidth=60)
## nice
Player %>%
  filter((play_count > meanP+4*stdP)==FALSE, (play_count < meanP-3.5*stdP) == FALSE) %>% 
  filter((S > meanS+4*stdS)==FALSE, (S < meanS-3.5*stdS) == FALSE) %>% 
  ggplot(aes(x = rank, y = S,color=play_count)) +
  #geom_point(mapping = aes(x = rank, y = A, color = play_count),color = "green",alpha=0.5,size = 1) +
  geom_point(size=1.0,alpha=0.5) +
  scale_color_gradient(low="white",high="blue")


Player2 <- Player %>%
  select(rank,play_count,SS,S,A) %>%
  filter((play_count > meanP+4*stdP)==FALSE, (play_count < meanP-3.5*stdP) == FALSE) %>% 
  filter((S > meanS+4*stdS)==FALSE, (S < meanS-3.5*stdS) == FALSE) %>%
  filter((SS > meanSS+4*stdSS)==FALSE, (SS < meanS-3.5*stdSS) == FALSE) %>%
  gather(key = key, value = "value", -rank, -play_count)

head(Player2)

ggplot(data = Player2) +
  geom_smooth(mapping = aes(x = rank, y = value,color = key))
  #geom_point(mapping = aes(x = rank, y = value, color = key), size = 0.25, alpha = 0.25) +
  #scale_y_continuous(limits = c(0,1200))
  #facet_wrap(. ~ key)

ggplot(data = Player2) +
  stat_summary(
    mapping = aes(x = key, y = value),
    fun.ymin = min,
    fun.ymax = max,
    fun.y = median
  )

ggplot(data = Player2) +
  geom_bar(mapping = aes(x = key, fill = key))
