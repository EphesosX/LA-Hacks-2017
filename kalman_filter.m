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
investment_share(1)=0;
liquid_share=zeros(size(interp_time));
liquid_share(1)=0;

% apply the Kalman filter to the model:
% x_1 - price of security
% x_2 - growth rate of price
% x_3 - coefficient of measurement
% x_4 - added to measurement
% transition: all constant except x_1
% z = x_3*x_2 + x_4

% initial guess
x=[1;0;10;0.3];
% covariance matrix
P=eye(4);
F=eye(4);F(1,2)=1;
r=0.01;
Q=eye(4);

for i=1:size(interp_time,2)-1
    % predict next price state
    x_hat=F*x;
    P_hat=P*F*P'+Q;
    % observe current price
    z_1=interp_price(i);z_2=interp_sentiment(i);
    H=[1,0,0,0;0,x(3),x(2),1];
    S=H*P_hat*H'+[r,0;0,r];
    K=P_hat*H'*S^-1;
    x=x_hat+K*[interp_price(i);interp_sentiment(i)];
    P=(eye(4)-K*H)*P_hat;
    
    if x(2)>0
        investment_share(i+1)=investment_share(i)-1;
        liquid_share(i+1)=liquid_share(i)+interp_price(i);
    else
        investment_share(i+1)=investment_share(i)+1;
        liquid_share(i+1)=liquid_share(i)-interp_price(i);
    end
end


figure(3)
clf
plot(1970+interp_time/3600/24/365,investment_share,'r')
hold on
plot(1970+interp_time/3600/24/365,liquid_share,'b')
plot(1970+interp_time/3600/24/365,interp_price-1,'k')
plot(1970+interp_time/3600/24/365,investment_share.*interp_price+liquid_share,'g')
