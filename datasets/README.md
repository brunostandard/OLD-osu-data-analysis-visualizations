# Overview of Dataset naming and Database Organization

This text briefly describes the datasets in this folder. This text also contains an extensive overview of the Relational database design (RDB) and the MySQL involved in this project. This project uses a local database to store, interact, and retrieve the osu! data. 

As of 8/28/2019, I now only have two datasets to worry about. They are currently named `test2.csv` and `test3.csv`. These files were obtained via web-scraping. More information about how I did can be found in the README.md in the `Python Code` folder. Web-scraping significantly reduced the number of files in this folder. 

## Datasets
File named `test2.csv` holds Player data from 2014 to early 2019. File `test3.csv` holds currrent Player data (08/31/2019). `test.csv` contains only the top 50 player data from 2014 to 2019. 

## Datasets : description
Every `.csv` should have the same format. 

|	Column	| Variable      | Description                       |
| ---------	|  ----------	|---------------------------------- |
|  	1	| `name`        | The player's name, partly unique  |
|  	2	| `performance` | Player's overall performance      |
|  	3	|  `accuracy`   | Player's average accuracy         |
|  	4	|	`PC`		| Total *P*lay *c*ount 			    |	
|  	5	| 	`SS` 		| Total number of SS rated beatmaps |
|  	6	| 	`S` 		| Total number of S rated beatmaps  |
|  	7	| 	`A` 		| Total number of A rated beatmaps  |
|  	8	| 	`Date` 		| Date of record					|


## Databases : Early version
The earliest version of the database was based on the following requirements:

- Player and player-data has to be one giant table
  - It was difficult to write python code that can systematically entered data into the database.
- The table `Player` should be index-able by `player_id` or `name`. 
- A `Song` table should have a many-to-many relationship with `Player` table. 
  - Having data of this type might be helpful some exploratory analysis. 
- A song should have index-able via `song_id` or `name`
  - name might be abbreviated. 

To answer the many-to-many relationship between tables `Player` and `Song`, a new table called `Manager` had to be implemented. The `Manger` table will also hold the following information:

- `player_id`
- `song_id`
- `performance`

In an attempt to have a more "accurate" data models, I wanted to have archived data. This data includes data from the years 2016, 2017, and 2018. I initially decided to just have a stand-alone tables for each year. It will have the same structure as Player table, but it won't have any relationships with other tables. 

![old_RDB_design](database_design/early_RDB_design.png)

## Databases : Second version 
There were some problems with the earlier version: 

1. There was a redundant column: `rank`. 
2. Poor data storage, i.e. too many stand alone tables. 

I realized `rank` was a useless variable if we had `performance`. We can find "rank" by arranging performance in descending order. There also was an issue with updating data: a player's rank changes daily if not hourly. 

I wanted to a single table containing the name of every player, retired or not. The player's statistics, new or old, can be stored in another table called `Stat`. This works really well since we can easily store a player's past data. For example, say we had a player named `JohnSmith`. Suppose there are three entries in the `Stat` table such that `Stat.player_id = Player.player_id` i.e. it belongs to `JohnSmith`. We can determine the most recent data with `performance` and `play_count` since they are are non-decreasing over time. 

![new_RDB_design](database_design/new_RDB_design.png)


For the sake for exploratory data analysis, I added new variables to the `Manager` table. to hold the following:
- player_id
- song_id
- performance
- score (new)
- accuracy (new)
- (combo information) (new)


This in turn will make sql queries a bit more complex.

This design has yet to be implemented as of 9/02/2019.

