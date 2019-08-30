"""
	This script creates a new .csv file with all the ranked data from the site osu.ppy.sh
	via webscraping. Module scraping_test is a local python script. It's pre-configured to
	go through the 200 pages of html.
	Advice: This script should be used occasionally. It was intended to be used occasionally. 
	My sessions last around 50 seconds before I get warning "too many requests". 
	Around 5 seconds for 10 pages
"""

import scraping_test
import bank
import csv

# create/open a csv file. 
f = open('new_player_data.csv', 'a')

# prepare for writing
w = csv.writer(f)

# example of expected data entries (sourced from the site osu.ppy.sh):
#row = ['bloo', '12372', '98.80', '126410', '93', '705', '614']

temp_data = scraping_test.scrape()

# entering data into the csv file
for row in temp_data:
	w.writerow(row)

# close that file now
f.close()
