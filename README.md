# LA-Hacks-2017
r/WorldNews Plays the Stock Market

## Inspiration
Reddit is one of the largest websites in the world, where people upvote and downvote posts to bring them to others' attention. r/WorldNews has millions of subscribers, commenting and contributing their opinions everyday. Through their collective wisdom, we can predict how portfolios of stocks associated with certain countries will perform, based on sentiment analysis of Reddit posts about those countries.
## What it does
Applies sentiment analysis to Reddit data to determine how Reddit "feels" about various topics, and simulates trading stocks accordingly.
## How we built it
Using Blackrock's Aladdin API, we pulled data for the performance of various stock portfolios over time. We also downloaded a data set from Kaggle containing Reddit data for r/WorldNews from 2008 onward. Putting that data into R, we performed sentiment analysis to determine the "mood" of the subreddit towards particular countries over time. Finally, putting that data into MATLAB, we created a market simulation, and simulated a trading strategy based on the sentiment of users, graphing the performance.
## Challenges we ran into
The lack of sufficiently strong wi-fi at the hackathon was a significant challenge; we were unable to start our hack for several hours due to difficulty obtaining our data. Also, I crashed my scooter Friday night and scraped my knee, which sucked.
## Accomplishments that we're proud of
Pretty graphs. Also the strategy works well, for what it is.
## What we learned
r/WorldNews is surprisingly good at predicting the stock market, for a crowd of random Internet people.
## What's next for r/WorldNews Plays the Stock Market
If we could get ahold of more Reddit data, we could create other packages of securities for associated subreddits. Also, the strategy could be refined more, and take into account differing opinions of topics to weight a portfolio.
