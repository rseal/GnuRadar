sampleRate = 64e6;
bandwidth = 1e6;
t = 1.0/bandwidth;
ipp=1e-3;
window=403;
dc=0.4;
ipps=100;
heights=bandwidth*ipp*dc;
fftSize = 8192;

fid = fopen("binary.dat","r");
data = fread(fid,"int16");
data = reshape(data, 4, length(data)/4);


of = 365;

%i and q channels 1 and 2
ch0 = data(1,of:end);
ix = zeros(1,length(ch0));
cnt=1;

for i=1:length(ch0)
  if( abs(ch0(i)) >= 2000) 
    ix(cnt)=i;
    i=i+400;
    cnt = cnt +1;
  end
end

ix = ix(1:cnt);
dx = zeros(1,length(ix));

for i=2:cnt-1
  dx(i-1) = abs(ix(i) - ix(i-1));
end

plot(dx);

%ch1 = data(2,of:end);
%ch2 = data(3,of:end);
%ch3 = data(4,of:end);
%size(ch0)
%ch0 = ch0(1:2400*window);

%length(ch0)/window

%ch0 = reshape(ch0,window,length(ch0)/window);
%ch0 = transpose(ch0);
% im = 0;
%ix = zeros(1,rows(ch0));

% for i=1:rows(ch0)
%   im=0;
%   for j=1:columns(ch0)
%     if(abs(ch0(i,j))>=im) 
%       im=ch0(i,j);
%       temp=j;
%     end
%   end
%   ix(i)=temp;
% end

% dx = zeros(1,rows(ch0)-1);
% for i=2:rows(ch0)-1
%   dx(i-1) = abs(ix(i) - ix(i-1));
% end

% plot(dx)
