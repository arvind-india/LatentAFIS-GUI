% �ӣɣӣ�ģ���ж�ȡ���ݣ�Ȼ���ʼ��һ��FPTemplateģ��
% 
% ����������
% T = LoadFPTemplateFromISO(file)
%
% ������
% �ú���ʵ��ISOģ���ļ��Ķ�ȡ���ܣ�����ISOģ�����ϸ����
% �뿴Doc�ļ����е�ISOTemplate.pdf ��
% SC37-19794-2FDIS.pdf�ļ���ISOģ��鿴���뿴ISOTemplateView.exe�ļ�
% 
% ���ã�
% T = LoadFPTemplateFromISO(file)
% 
% ���룺
% file - isoģ���ļ���
%
% �����
% ��ȡ��ϸ�ڵ����ݣ�ϸ�ڵ��������ȵȶ����浽��Ӧ��������
% �����ȡ��������Ҫ��ISO�б�����ʲô����
% 
% ���ӣ�
% T = LoadFPTemplateFromISO('testimages/fing.ist');
% T.Img = imread('testimages/fing.bmp');
% ShowMnt(T);
%
% SEE ALSO SaveFPTemplateToISO, ReadISOUserDefinedExtendData 
%
function T = LoadMinutiaeFromISO(file)

% ���ļ�
fid = fopen(file, 'r');
if fid == -1
    error(['�޷���ISOģ���ļ�: ' file]);
end

%��ȡ����
%%
% ��ȡ�ļ�ͷ
[ID, Version, RecLen, CEC, CDT, ImSize, HRes, VRes, NumView] = readisofileheader(fid);
if(strcmp(ID(1:3), 'FMR')~=1)
    error(['�ļ�' file '��һ����ISOϸ�ڵ�ģ���ļ�']);
end

% ��ȡÿһ��finger View������
% ���ļ�ָ����õ�ָ���һ��view
fseek(fid, 1, 'cof');
% T = FPTemplate(1,NumView);% Ԥ�ȳ�ʼ��һ��ָ��ģ�����飬�����С����NumView
for k=1:NumView
    T(k) = readviewdata(fid);
    T(k).ImageSize = ImSize;
    T(k).HRes = HRes;
    T(k).VRes = VRes;
end

% �ر��ļ�
fclose(fid);

if nargin == 0
    % ֻ��ʾ��һ��view
%     T(1).Img = im;
%     ShowMnt(T(1),'shownumber', 'on');
%     hold on;ShowSP(T(1));hold off;
end

function [ID, Version, RecLen, CEC, CDT, ImSize, HRes, VRes, NumView] = readisofileheader(fid)
%
% ��ȡ�ļ�ͷ
% 
% ģ���ļ���ʶ��
fseek(fid, 0, 'bof');
ID = fread(fid, 4, '*char')';

% ��ȡ�汾��
Version = fread(fid, 4, '*char')';

% ��ȡģ���ܳ���
RecLen = fread(fid, 1, 'uint32', 0, 'b');

% ��ȡ�ɼ��豸��֤��Ͳɼ��豸ID��
code = fread(fid, 1, 'uint16', 0, 'b');
c = dec2bin(code, 16);
CEC = bin2dec(c(1:4));  % ǰ�ĸ����ر�ʾCapture Equipment Certification
CDT = bin2dec(c(5:16)); % ��12���ر�ʾ�ɼ��������̱�ʶ��

% ��ȡͼ��ߴ�
ImSize = fread(fid, 2, 'uint16', 0, 'b');
ImSize = ImSize(end:-1:1)';

% ��ȡͼ��ֱ���
HRes = fread(fid, 1, 'uint16', 0, 'b');
VRes = fread(fid, 1, 'uint16', 0, 'b');

% ��ȡNumber of Views
NumView = fread(fid, 1, 'uint8', 0, 'b');


function [T, ViewNumber] = readviewdata(fid)
%
% ��ȡ�ļ��е�ÿһ��view�����ݣ�������Tģ��
% �ļ���ʶ��fid�����Ѿ�������view�����ݿ�ͷ
% 

% ��ȡPosition����
T.Position = fread(fid, 1, 'uint8',0,'b');

% ��ȡViewNumber��Impression Type
c = fread(fid, 1, 'uint8', 0, 'b');
c = dec2bin(c, 8);
ViewNumber = bin2dec(c(1:4));
T.ImpressionType = bin2dec(c(5:8));

% ��ȡϸ�ڵ�����
T.Quality = fread(fid, 1, 'uint8', 0, 'b');

% ϸ�ڵ�����
NumMnt = fread(fid, 1, 'uint8', 0, 'b');

% �����ȡϸ�ڵ�����
MntXY = zeros(NumMnt,2);
MntAngle = zeros(NumMnt,1);
MntType = zeros(NumMnt,1);
MntQuality = zeros(NumMnt,1);
for k=1:NumMnt
    c = fread(fid, 1, 'uint16', 0, 'b');c = dec2bin(c,16);
    MntType(k) = bin2dec(c(1:2));
    MntXY(k,1) = bin2dec(c(3:16));
    c = fread(fid, 1, 'uint16', 0, 'b');c = dec2bin(c,16);
    MntXY(k,2) = bin2dec(c(3:16));
    
    c = fread(fid, 2, 'uint8', 0, 'b');
    MntAngle(k) = c(1);
    MntQuality(k) = c(2);    
end
T.MntXY = MntXY;
T.MntAngle = mod(MntAngle * 2*pi/255, 2*pi);  % ���Ƕ�ת��ΪMatlab�ĳ��ø�ʽ
T.MntType = MntType;
T.MntQuality = MntQuality;


%% ���¶�ȡ��չ����


% ��չ����������
ExtDataLen = fread(fid, 1, 'uint16', 0, 'b');
if ExtDataLen == 0,return;end % Ϊ0˵��û����չ���ݣ�ֱ���˳�

% ��չ���ݵ�����������������ʶ�����ͱ�ʶ��ռ�����ַ����������ݵı�ʶ�����±���ʾ��
%---------------------------------------------------------------%
% First byte    Second byte     Identification
% 0x00          0x00            reserved
% 0x00          0x01            ridge count data (7.5.2)
% 0x00          0x02            core and delta data (7.5.3)
% 0x00          0x03            zonal quality data (7.5.4)
% 0x00          0x04-0xFF       reserved
% 0x01-0xFF     0x00            reserved
% 0x01-0xFF     0x01-0xFF       vendor-defined extended data
%----------------------------------------------------------------%
% Ҫ��ISOģ����֧���Լ��������չ���ݣ�����Ҫ�Լ�����һЩ���ͱ�ʶ��
% ��ͬ����չ���ݣ���洢��ʽҲ��һ����������Ҫ��Բ�ͬ����չ����д��ͬ�Ķ�ȡ����
% ���³���ѭ����ȡ��չ���ݣ�ֱ���������ݶ���ȡ������������֧�ֵ���չ��������ԣ����������棡��

% ��¼�´�ʱ�ļ�ָ���λ��
PositionExtData = ftell(fid);
while 1 %���ڲ�֪���м�����չ���ݣ�������ѭ���м���ܵ���չ���ݳ��ȣ�Ȼ����break����
    % ����Ѿ���ȡ����չ���ݳ��ȵ�����չ�����ܳ��ȣ����˳�ѭ��
    PositionNow = ftell(fid);
    if PositionNow-PositionExtData==ExtDataLen,break;end
    
     % ���ȶ�ȡ��չ���ݱ�ʶ��
    ExtDataID = fread(fid, 1, 'uint16', 0, 'b');
    switch ExtDataID
        case 0      %����������
            error('��չ�������ͱ�ʶ0Ϊ�������֣������ļ��Ƿ��𻵣�');
        case 1      % Ridge count ����
            [MntRidgeCount, Method] = readisoridgecount(fid);
            T.MntRidgeCount = MntRidgeCount;
            T.MntRidgeCountMethod = Method;
        case 2      % ���������
            % ��չ���ĳ���
            AreaDataLen = fread(fid, 1, 'uint16', 0, 'b');
            [core, delta, coreinfo, deltainfo] = readisosingular(fid);
            T.CoreXY = core(:,1:2);
            if coreinfo==1,T.CoreAngle = core(:,3);end
            T.DeltaXY = delta(:,1:2);
            if deltainfo==1,T.DeltaAngle = delta(:,3:end);end
        case 3      % zonal��������
            ;
        otherwise   % ��������Լ�����ĺ�������ȡ
            T = ReadISOUserDefinedExtendData(fid, ExtDataID, T);
    end
end

function [MntRidgeCount, Method] = readisoridgecount(fid)
%
%
% ����������
AreaLen = fread(fid, 1, 'uint16', 0, 'b');

% �����ܹ��ļ��߼�����������
NumPair = (AreaLen-1)/3;
MntRidgeCount = zeros(NumPair, 3);

% ��ȡϸ�ڵ㼹�߼�������
Method = fread(fid, 1, 'uint8', 0, 'b');

% ��Զ�ȡ
for k=1:NumPair
    MntRidgeCount(k,1:3) = fread(fid, 3, 'uint8', 0, 'b');
end


function [core, delta, coreinfo, deltainfo] = readisosingular(fid)
% ��ȡcore��
c = fread(fid, 1, 'uint8',0,'b');c = dec2bin(c, 8);
NumCore = bin2dec(c(3:8));
core = zeros(NumCore, 3);
for k = 1:NumCore
    c = fread(fid, 1, 'uint16', 0, 'b');c = dec2bin(c,16);
    coreinfo = bin2dec(c(1:2));
    core(k,1) = bin2dec(c(3:16));
    c = fread(fid, 1, 'uint16', 0, 'b');c = dec2bin(c,16);
    core(k,2) = bin2dec(c(3:16));
    if coreinfo==1 % �����Ƕ���Ϣ
        angle = fread(fid,1,'uint8', 0, 'b');
        core(k,3) = mod(-angle*2*pi/255, 2*pi);
    end
end

% ��ȡDelta��
c = fread(fid, 1, 'uint8',0,'b');c = dec2bin(c, 8);
NumDelta = bin2dec(c(3:8));
delta = zeros(NumDelta, 5);
for k = 1:NumDelta
    c = fread(fid, 1, 'uint16', 0, 'b');c = dec2bin(c,16);
    deltainfo = bin2dec(c(1:2));
    delta(k,1) = bin2dec(c(3:16));
    c = fread(fid, 1, 'uint16', 0, 'b');c = dec2bin(c,16);
    delta(k,2) = bin2dec(c(3:16));
    if deltainfo==1 % �����Ƕ���Ϣ
        angle = fread(fid,3, 'uint8', 0, 'b');
        delta(k,3:5) = mod(-angle*2*pi/255, 2*pi);
    end
end