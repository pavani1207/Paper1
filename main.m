
tic
clc
clear;
close all

% Test image
img_dir = 'C:\Users\Datasets\';

% get a list of all the files in the directory
file_list = dir([img_dir '*.jpg']);
for i = 1:length(file_list)
    % get the file name
    filename = [img_dir file_list(i).name];
    % read the image
    img = imread(filename);
    Y = rgb2gray(img); 
    Y=double(Y);
    YY{i}=Y;
    % imshow(Y);
    % Apply Collatz transform for nth round
    cn = 10;% key
    [II,map1] = modified_collatz(Y,cn);

    % We compute the Fresnel transform of the test image
    lambda=632.8e-9; % Wavelength in meters
    d = 0.01; % distance in meters
    T = 10e-6; % sampling distance between pixels
    tau=sqrt(lambda*d); % tau parameter, by definition
    fres=fresnelet_transform(II, tau, T, 1);
    %  hash generation
    Mhash{i}=hash(fres);
end

 %  scrambled watermark generation
w=imread("watermark2.jpg");
% wII=imresize(w,[64,64]);
wII=imresize(rgb2gray(w),[64,64]);
WI = double(wII); % I stores the nth iteration output of collatz transform 
n = 5;  % number of iteration or round (used as key)
[wkey,wmap]=modified_collatz3d(WI,n);

% scrambling of collatz watermark using choatic 
CHKEY = ceil(rand(1,max(64,64)).*255);
CSWM=echoatic(wkey,CHKEY);

for i=1:10
%key 
key{i}=bitxor(Mhash{i},CSWM);
end

toc
tic
% attacked image

for k = 1:length(file_list)
    AY1{k}=attackfun(YY{k});
    for i=1:51
        for j=1:10
         
            AA=AY1{k};
            if (~isempty(AA{i,j}))
                AY=double(AA{i,j});

                % imshow(AY);
                % Apply Collatz transform for nth round
                An = 10;
                [AII,Amap1] = modified_collatz(AY,An);

                % We compute the Fresnel transform of the test image
                Afres=fresnelet_transform(AII, tau, T, 1);
                AHash{k}=Ahash(Afres); 

                %retrieve scrambled choatic watermark usinh HASH
                CSWM1=bitxor(AHash{k},key{k}); 

                % retreive scrambled collatz watermark using choatic sequence
                wkey1=dchoatic(CSWM1,CHKEY);

                %retreive scrambled   watermark using Collatz transform  
                rwam=modified_collatz_rev3d(wkey1,wmap,n); 
                S1(i,j)=ssim(rwam,WI);
                S2(i,j)=ssim(CSWM,CSWM1);
                S3(i,j)=ssim(wkey,wkey1);

                P1(i,j)=psnr(WI,rwam);
                P2(i,j)=psnr(CSWM1,CSWM);
                P3(i,j)=psnr(wkey1,wkey);

                N1(i,j)=nc2d(rwam,WI);
                N2(i,j)=nc2d(CSWM1,CSWM);
                N3(i,j)=nc2d(wkey1,wkey);
                
            end
        end
    end
   SW1{k}=S1;
   SW2{k}=S2;
   SW3{k}=S3;

   PW1{k}=P1;
   PW2{k}=P2;
   PW3{k}=P3;

   NC1{k}=N1;
   NC2{k}=N2;
   NC3{k}=N3;
   
end
toc    
