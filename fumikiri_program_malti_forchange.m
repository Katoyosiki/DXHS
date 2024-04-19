%踏切の音だけ消音するある
%完成形
clear;
close all;
[yy,fs] = audioread('fumikiri_sound.wav'); %音声読み込み
info=audioinfo('fumikiri_sound.wav');     %詳細読み込み
M=info.TotalSamples;    %トータルの数読み込み M トータルの数

firstnoise=[yy(1:36000)];      %特定の行を抽出

%DCHSアルゴリズム作成
%初期値設定
fs_d=[696,746,1392,1492,2789,2984,3483,3730,2088,2238] ;  %消したい音の周波数 ふぁ　ふぁ# ふぁ ふぁ#　ど ど＃

rad=[2*pi*fs_d(1),2*pi*fs_d(2),2*pi*fs_d(3),2*pi*fs_d(4),2*pi*fs_d(5),2*pi*fs_d(6),2*pi*fs_d(7),2*pi*fs_d(8),2*pi*fs_d(9),2*pi*fs_d(10)]; %消したい音の角周波数

mu_step=0.04;   %ステップパラメータゲイン
mu_rad=0.01; %ステップパラメータ位相

w=[zeros(30,1)]; %重みの初期化　上から　[alph, beta, fai]
y=zeros(1,36000); %出力初期化
e=zeros(1,36000); %誤差初期化

%アルゴリズム開始
for i=1:length(firstnoise)
   for j=1:10
       if j<5
          y(i)=y(i)+w(j)*cos(rad(j)*i*(1/fs)+w(20+j));
       end
       y(i)=y(i)+w(j)*cos(rad(j)*i*(1/fs)+w(20+j));
   end
   
   for j=1:10
       if j<5
           y(i)=y(i)+w(10+j)*sin(rad(j)*i*(1/fs)+w(20+j)) ;
       end
       y(i)=y(i)+w(10+j)*sin(rad(j)*i*(1/fs)+w(20+j)) ;
   end
   e(i)=y(i)+firstnoise(i);
   
   %重み更新
   for j=1:10
      w(j)=w(j)-2*mu_step*e(i)*cos(rad(j)*i*(1/fs)+w(20+j));
      
   end
   for j=1:10
      w(j+10)=w(j+10)-2*mu_step*e(i)*sin(rad(j)*i*(1/fs)+w(20+j));
      
   end
   for j=1:10
     w(j+20)=w(j+20)-2*mu_rad*e(i)*(-w(j)*sin(rad(j)*i*(1/fs)+w(20+j)) + w(j+10)*cos(rad(j)*i*(1/fs)+w(20+j)));
   end
   
end

%フーリエ変換実験後
fft_first_noise=fft(firstnoise);
fft_first_noise=abs(fft_first_noise);
f = (0:length(fft_first_noise)-1)*fs/length(fft_first_noise);
fft_result=fft(e);
fft_result=abs(fft_result);
figure(2);
semilogy(f,fft_first_noise);
hold on;
semilogy(f,fft_result);
 title("Spectrum",'fontsize',15);
xlabel('frequency[Hz]')
ylabel('magnitude[dB]')
xlim([0 4000]);
ylim([0.001 1000]);
grid on;
h_axes = gca;
h_axes.XAxis.FontSize = 15;
h_axes.YAxis.FontSize = 15;
legend("before ANC","proposed method",'fontsize',15);
sound(e,fs);

audiowrite('result.wav',e,fs);








