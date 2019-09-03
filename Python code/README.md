## Overview
This folder contains some files in regards to webscraping. 

When a url or record is referred to as "new", this means that the url is what we would find [online](https://osu.ppy.sh/rankings/osu/performance) as of mid 2019. When a url or record is reffered to as "old", the url is actually from the web-app called the WayBack Machine. These old urls allow us to obtain records of past Leaderboard data. 

## Description

- `scraper.py` is the main script used to scrape from the site osu.ppy.sh.
- `scraper_v2.py` is the another script used to scrape old urls of osu.ppy.sh. 
- `bank.py` contains lists of urls from which we want to scrape from. 
- `web_scrape.py` is an auxillary script that contains the parsing algorithms for new web urls. 
- `web_scrape_v2.py` is an auxillary script that contains the parsing algorithms for old web urls. 
- `mixed_web_scrap.py` is a mix of the first two scripts. It was used to do some web-scraping from both new and old urls. 
- `test_csv_gen.py` is a script demonstrating how to write on csv files. It's there for educational purposes. 

## Notes
What's amazing here is the result of this web-scraping. I've gathered 10,000 rows of data within minutes. Last time, it took close to an hour to get 5,000 rows of data, and that is counting all the filtering and formatting. 

Watch [this video](https://www.youtube.com/watch?v=XQgXKtPSzUI) to learn how I learned web-scraping. 
