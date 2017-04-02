% r/WorldNews Plays the Stock Market

% LA Hacks 2017
% 3/31/17-4/2/17 

% Lisa Cheng | Daniel Lui | Thomas Tu
%    UCLA    |     UCR    |  UCLA

% Devpost URL: https://devpost.com/software/r-worldnews-plays-the-stock-market

% Summary: This code initially prompts user input to select a country, and 
% then outputs three graphs which describe displays the specified data.

% IMPORTANT: Needs china.mat, russia.mat, amd world.mat to run properly 

clearvars
% Prompts user input to select country
disp('Enter one of the following country codes')
disp('China [CN], Russia [RU], United Kingdom [UK]')
a=input('Input country code as a string []: ');

if strcmp(a,'CN')==1
    load('china.mat')
elseif strcmp(a,'RU')==1
    load('russia.mat')
elseif strcmp(a,'UK')==1
    load('uk.mat')
else
    disp('Error: Please input a functional country code')
end

% Initialize parameters
n=1; s=sentiment(1); 
wavg_sentiment=zeros(size(time));
wavg_sentiment(1)=s;

% Initizalize upvotes data
wavg_upvotes(1)=up_votes(1);
s_upvotes=max(up_votes(1),20); %sum of upvotes

% Calculuates windowed average for sentiment
for i=2:size(time,1)
    if up_votes(i)>20 %Filters out lower ranking posts (<20 votes)
        s=s+sentiment(i)*up_votes(i)/s_upvotes*(i-n+1);
        s_upvotes=s_upvotes+up_votes(i); 
    end
    while time(i)-time(n)>3600000*24*7*4 %360000*24*7*4 converts UNIX Epoch time to months
        if up_votes(n)>20 
            s=s-sentiment(n)*up_votes(n)/s_upvotes*(i-n+1);
            s_upvotes=s_upvotes-up_votes(i);
        end
        n=n+1;
    end
    wavg_sentiment(i)=s/(i-n+1); %Windowed average for sentiment
end

%Plots 
% figure(1)
% clf
% plot(1970+time/3600/24/365,wavg_sentiment)
% hold on
% plot(1970+p_time/1000/3600/24/365,price-1,'k')
% title('Sentiment and Stock Price over time')
% xlabel('time(year)')
% ylabel('unitless')
% legend('Sentiment','Stock Price')
% hold off

% Initializes interpolated data for time
interp_time=max(time(1),p_time(1)/1000):3600:min(time(end),p_time(end)/1000);
unique_time=unique(time); %Elimiates time repeats from the Reddit data
monotone_sentiment=zeros(size(unique_time)); %initialize sentiment to line up with time
j=1;

% Makes sentiment data line up to monotinc time
for i=1:size(unique_time,1)
    s_mono=0;n_mono=0; 
    while j<size(time,1) && time(j)<=unique_time(i) && isnan(wavg_sentiment(j))==0
        s_mono=s_mono+wavg_sentiment(j);
        n_mono=n_mono+1;
        j=j+1;
    end
    if n_mono~=0
        monotone_sentiment(i)=s_mono/n_mono;
    else
        monotone_sentiment(i)=monotone_sentiment(i-1);
    end
end

% Interpolates sentiment and price data
interp_sentiment=interp1(unique_time,monotone_sentiment,interp_time);
interp_price=interp1(p_time/1000,price,interp_time);

% Plots interpolated data
figure(2)
clf
plot(1970+interp_time/3600/24/365,interp_sentiment,'b')
hold on
plot(1970+interp_time/3600/24/365,interp_price-1,'k')
title('Sentiment and Stock Price over time')
xlabel('Time(year)')
% ylabel('unitless')
legend('Sentiment','Stock Price(percent gain)')
hold off

% Trading Algorithm

% Initializes investment share (amount of money in portfolio)
investment_share=zeros(size(interp_time));
investment_share(1)=100/interp_price(1); %Initializes starting investment at $100 worth of stock

% Initializes liquid share (amount of moneey as cash) 
liquid_share=zeros(size(interp_time)); 
liquid_share(1)=100; %Initializes starting liquid cash amount as $0

% Initializes mean sentiment at 0
mean_sentiment=0; n_mean=0;

% Simulation that calculates mean sentiment and performs buying pattern
% according to deviations from the mean sentiment
m_sent=zeros(size(interp_time));
sent_speed=zeros(size(interp_time));

i_share2=investment_share;
l_share2=liquid_share;
for i=1:size(interp_time,2)-1
    price_speed=(interp_price(i)-interp_price(max(1,i-10)));
    sentiment_speed=interp_sentiment(i)-mean_sentiment;
    sent_speed(i)=interp_sentiment(i)-mean_sentiment;
    trade_quantity=sent_speed(i)/4;%50*price_speed+sent_speed(i)/10;
    investment_share(i+1)=investment_share(i)+trade_quantity;
    liquid_share(i+1)=liquid_share(i)-trade_quantity*interp_price(i);
    trade_quantity2=price_speed*500;
    i_share2(i+1)=i_share2(i)+trade_quantity2;
    l_share2(i+1)=l_share2(i)-trade_quantity2*interp_price(i);
    mean_sentiment=(mean_sentiment*n_mean+interp_sentiment(i))/(n_mean+1);
    n_mean=n_mean+1;
    m_sent(i)=mean_sentiment;
end

% Plots Performance
figure(3)
clf
% plot(1970+interp_time/3600/24/365,investment_share.*interp_price,'r')

hold on
% plot(1970+interp_time/3600/24/365,liquid_share,'b')
plot(1970+interp_time/3600/24/365,200*interp_price/interp_price(1),'k')
plot(1970+interp_time/3600/24/365,200*ones(size(interp_price)),'k')
plot(1970+interp_time/3600/24/365,investment_share.*interp_price+liquid_share,'g')
plot(1970+interp_time/3600/24/365,i_share2.*interp_price+l_share2,'b')
title('Return on Investment ($200)')
xlabel('Time(year)')
ylabel('Money($USD)')
legend('Stock Price', 'Baseline', 'Our Strategy','Price Momentum','Location','best')
hold off

