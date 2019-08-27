"""
	This script creates a new .csv file with all the ranked data from the site osu.ppy.sh
	via webscraping. Module scraping_test is a local python script. It's pre-configured to
	go through the 200 pages of html.
	Advice: This script should be used occasionally. It was intended to be used occasionally. 
	My sessions last around 50 seconds before I get warning "too many requests". 
	Around 5 seconds for 10 pages
"""

import scraping_test
import csv

f = open('new_player_data.csv', 'a')
w = csv.writer(f)

#row = ['bloo', '12372', '98.80', '126410', '93', '705', '614']
temp_data = scraping_test.scrape()
for row in temp_data:
	w.writerow(row)
f.close()
	#filewriter = csv.writer(csvfile, delimiter=',',
	#						quotechar='|', quoting=csv.QUOTE_MINIMAL)
	#temp_data = scraping_test.scrape()
	#for row in temp_data:
	#	filewriter.writerow(row)
