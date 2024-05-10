# -*- coding: utf-8 -*-
"""
Created on Fri Feb  9 12:18:22 2024

@author: joshd
"""
 #imports libaries
import requests as r 
import csv 
from bs4 import BeautifulSoup
import time
import random as ran
#sets high and low value for throttoling
highint = 4 
lowint = 1
#creates filepath/filename and parent url
filepath = r'C:\\Users\\joshd\\Desktop\\Portfolio\\Python\\Web Scraping\\'
filename = 'Web Scraping Project fileout.csv'
parenturl = 'http://drd.ba.ttu.edu/isqs3358/hw/hw1/'
#accesses parent url and breakts it into soup
res = r.get(parenturl)
print(res.status_code)
soup = BeautifulSoup(res.content, 'lxml')
userindex = soup.find('div', attrs={'id':'UsrIndex'}).find_all('tr')
#cretes file with headers
with open(filepath + filename, 'w', newline='', encoding='utf-8') as dataout:
    datawriter = csv.writer(dataout, delimiter=',', quotechar='"', quoting=csv.QUOTE_NONNUMERIC)
    datawriter.writerow(['Rank', 'user_id', 'fname', 'lname','avg_water', 'avg_sleep',
                         'avg_step', 'day', 'day_water_amt', 'day_sleep_amt', 'day_step_amt', 'metric'])
    #runs loop to get information from parent url
    for n in userindex[1:]:
        td = n.find_all('td')
        href = td[0].find('a')['href']
        split = href.split('=')
        key = split[1]
        rank = td[1].text
        name = td[2].text
        avg_sleep = td[3].text
        avg_water = td[4].text
        avg_steps = td[5].text
        metric = td[6].text
        #creates child url and gets basic info 
        childurl = r.get(parenturl + href)
        childsoup = BeautifulSoup(childurl.content, 'lxml')
        #subsets child child url to extract info
        userdetail = childsoup.find('div', attrs = {'id': 'UsrDetail'})
        sub = userdetail.find_all('tr')
        #runs loop to get extracted info
        for i in sub[1:]:
            ctd = i.find_all('td')
            day = ctd[0].text
            sleep = ctd[1].text
            water = ctd[2].text
            steps = ctd[3].text
            #inserts data into csv
            datawriter.writerow([rank, key, name.split(' ')[0], name.split(' ')[1], avg_water, avg_sleep, avg_steps,
                                    day, water, sleep, steps, metric])
        #throttles loop
        interval = ran.randint(lowint, highint) + ran.random()
        time.sleep(interval)
        

