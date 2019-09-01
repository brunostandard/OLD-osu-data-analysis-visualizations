# find all tr class = "row1p" and "row2p"
# name is 

import bs4
from urllib.request import urlopen as uReq
from urllib.request import Request
from bs4 import BeautifulSoup as soup

def scrape_v2(my_url):
	"""
		The thing that calls this function is responsible for giving the url. That url should contain
		the performance tables (rankings) of a specific format. That is, the html page is expected to be
		the earlier version of osu.ppy.sh before late 2018.
	"""
	req = Request(my_url, headers={'User-Agent': 'Mozilla/5.0'})
	uClient = uReq(req)
	page_html = uClient.read()
	page_html = page_html.decode('utf-8')
	uClient.close()

	page_soup = soup(page_html,"html.parser")

	# there are two types of tr-s, but they are the same thing. I think the html colors are different. 
	containers = page_soup.findAll("tr",{"class":"row1p"})
	containers.extend(page_soup.findAll("tr",{"class":"row2p"}))

	final_output = []

	for container in containers:
		# There are just three elements in this variable. The map counts SS/S/A. 
		map_count_container = container.findAll("td",{"align":"center"})
		map_count = [e.text.replace(",","") for e in map_count_container]

		# extracting name. 
		container.td.findAll("",{"class ":""})

		# extracting everything else. Each element is in a td
		temp = container.findAll("td")

		# just grab the text. don't deal with anyother html from here on out
		temp = [e.text for e in temp]

		# the rest is simple once we know how things are ordered
		# in particular, (rank, name, accuracy, play_count, performance, SS, S, A)
		# ['#251', ' putigame', '99.05%', '86,506 (lv.101)', '\n5,453pp\n', '1,531', '1,848', '32']

		name = temp[1].strip()

		acc = temp[2].replace("%","")

		play_count = temp[3][:temp[3].find("(")].strip().replace(",","")

		performance = temp[4].replace("\n","").replace("pp","").replace(",","")

		final_row = [name, performance, acc, play_count]

		# Now just putting everything together. 
		final_row.extend(map_count)

		# add our row to the collection
		final_output.append(final_row)
	return final_output
