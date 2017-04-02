n=1;
s=sentiment(1);
wavg_sentiment=zeros(size(time));
wavg_sentiment(1)=s;
wavg_upvotes(1)=up_votes(1);
s_upvotes=up_votes(1);
for i=2:size(time,1)
    if up_votes(i)>20
        s=s+sentiment(i)*up_votes(i)/s_upvotes*(i-n+1);
        s_upvotes=s_upvotes+up_votes(i);
    end
    while time(i)-time(n)>3600000*24*7*4
        if up_votes(n)>20
            s=s-sentiment(n)*up_votes(n)/s_upvotes*(i-n+1);
            s_upvotes=s_upvotes-up_votes(i);
        end
        n=n+1;
    end
    wavg_sentiment(i)=s/(i-n+1);
end
figure(1)
clf
plot(1970+time/3600/24/365,wavg_sentiment)
hold on
plot(1970+p_time/1000/3600/24/365,price-1,'k')

interp_time=max(time(1),p_time(1)/1000):3600:min(time(end),p_time(end)/1000);
unique_time=unique(time);
monotone_sentiment=zeros(size(unique_time));
j=1;
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

interp_sentiment=interp1(unique_time,monotone_sentiment,interp_time);
interp_price=interp1(p_time/1000,price,interp_time);
figure(2)
clf
plot(1970+interp_time/3600/24/365,interp_sentiment,'b')
hold on
plot(1970+interp_time/3600/24/365,interp_price,'k')

investment_share=zeros(size(interp_time));
investment_share(1)=100/interp_price(1);
liquid_share=zeros(size(interp_time));
liquid_share(1)=0;
mean_sentiment=0;n_mean=0;
for i=1:size(interp_time,2)-1
    mean_sentiment=(mean_sentiment*n_mean+interp_sentiment(i))/(n_mean+1);
    n_mean=n_mean+1;
    investment_share(i+1)=investment_share(i)-(interp_sentiment(i)-mean_sentiment)/1000;
    liquid_share(i+1)=liquid_share(i)+interp_price(i)*(interp_sentiment(i)-mean_sentiment)/1000;
end
figure(3)
clf
% plot(1970+interp_time/3600/24/365,investment_share.*interp_price,'r')
hold on
% plot(1970+interp_time/3600/24/365,liquid_share,'b')
plot(1970+interp_time/3600/24/365,100*interp_price,'k')
plot(1970+interp_time/3600/24/365,100*ones(size(interp_price)),'k')
plot(1970+interp_time/3600/24/365,investment_share.*interp_price+liquid_share,'g')
