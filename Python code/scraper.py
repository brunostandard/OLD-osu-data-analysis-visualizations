"""
	This script creates a new .csv file with all the ranked data from the site osu.ppy.sh
	via webscraping. Module scraping_test is a local python script. It's pre-configured to
	go through the 200 pages of html.
	Advice: This script should be used occasionally. It was intended to be used occasionally. 
	My sessions last around 50 seconds before I get warning "too many requests". 
	Around 5 seconds for 10 pages
"""
import web_scrape
import bank
import csv

# create/open a csv file. 
f = open('test3.csv', 'a')

# prepare for writing
w = csv.writer(f)

# example of expected data entries (sourced from the site osu.ppy.sh):
#row = ['bloo', '12372', '98.80', '126410', '93', '705', '614']
page_number = 1
max_page_number = 201
final_data = []
todays_date = "2019-08-31"
my_url = "https://osu.ppy.sh/rankings/osu/performance?page=**#scores"
for page_number in range(181,201):
	temp_my_url = my_url.replace("**",str(page_number))
	temp_data = web_scrape.scrape(temp_my_url)
	print("successful scrape")
	for row in temp_data: # for each row in temp data
		row.append(todays_date)
		w.writerow(row)

# close that file now
f.close()
