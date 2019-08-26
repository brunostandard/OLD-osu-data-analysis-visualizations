Osu! Data Analysis (version 0.00)

Developer
----------------------------------------------------------------
M.C. 
- email : man uelc 15 45 (at) hotmail (dot) com

Requirements
----------------------------------------------------------------
- R version 3.4.4 (2018-03-15), for R code and notebooks
- Python 3.7.3, for python code and notebooks
- Jupyter Notebook 4.4.0
- (optional) conda 4.6.11 to use Jupyter Notebooks
- A MySQL server (locally hosted)
 

Description
----------------------------------------------------------------
This is a personal project.

Osu! is a rythm-based game from [osu.ppy.sh](https://osu.ppy.sh/home). You play songs and click cricles. If you are really good at clickling circles, you can show up on the [leaderboard](https://osu.ppy.sh/rankings/osu/performance). What does it take to ascend to the top?

This is an analysis of ranked data. The are several parts to this analysis. The following are the steps I took:
1. Copy data from [osu.ppy.sh](https://osu.ppy.sh/rankings/osu/performance) (by hand)
2. Copy data from osu.pppy.sh (by hand) with the way back machine for older ranked data. 
3. Format the raw data with python
	- Some visualizations is done here too.
4. Use python to import the "formatted" data onto a local mysql database. 
	- This part is for having a database to store data. 
	- This is also a method for learning mysql and relational databases. 
	- This will be expanded upon more. 
5. Use R to produce more visualizations and describe a model. 
	- Learned R in the process.


Licensing and Acknowledgments 
----------------------------------------------------------------
This is a personal project designed for educational purposes. I do NOT condone academic-plagiarism, but this repo is free to use for creative use.
Acknowledgments to peppy (Dean Herbert) for site [osu.ppy.sh](https://osu.ppy.sh/home) and Game Osu!. It's a great game. 

