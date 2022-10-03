function [] = main()

close all;
clear all;

disp('Dynamic Window Approach program with dynamic obstacles start!!')

%% �����˵�״̬[x(m),y(m),yaw(Rad),v(m/s),w(rad/s)]

x = [0 0 pi/10 0 0]'; % ��ֵ��ʼ״̬: 5x1���� �о��� λ��(0,0) ����pi/10 ,�ٶȡ����ٶȾ�Ϊ0

% �±�궨�� ״̬[x(m),y(m),yaw(Rad),v(m/s),w(rad/s)]
POSE_X      = 1;  %���� X
POSE_Y      = 2;  %���� Y
YAW_ANGLE   = 3;  %�����˺����
V_SPD       = 4;  %�������ٶ�
W_ANGLE_SPD = 5;  %�����˽��ٶ� 

goal = [10,10];   % Ŀ���λ�� [x(m),y(m)]

%% �ϰ���״̬�б� [x(m) y(m) yaw(Rad) v(m/s) w(rad/s)]
%  Ĭ���ϰ����Ժ㶨�ٶ����У���yaw,v,w=0

% obstacle=[0 2 0     0.2 0 ;
%           2 4 pi/10 0.1 0 ;
%           2 5 pi/2  0.1 0 ;      
%           4 2 pi/2  0.1 0 ;
%           5 4 pi/2  0.1 0 ;
%           5 6 pi/2  0.1 0 ;
%           5 9 pi/2  0.1 0 ;
%           8 8 pi/2  0.1 0 ;
%           8 9 pi/2  0.1 0 ;
%           7 9 1.5*pi  0.1 0 ;
%           ]';

%% ��������ϰ�״̬��Ϣ
% �ϰ�����
number_of_obstacle = 20;
% Ϊ��ʹ���ϰ���x��y������1-9֮��(����С��)��yaw��0-2*pi[rad]֮�䣬v��0-0.5[m/s],w=0
% rad/s,����ϵ��A_ob��B_ob����
A_ob=[8 0    0   0 0;
      0 8    0   0 0;
      0 0 2*pi   0 0;
      0 0    0 0.5 0;
      0 0    0   0 0];

B_ob=[1 1 0 0 0];
B_ob=repmat(B_ob,number_of_obstacle,1);

% �����ϰ�״̬�����б�
obstacle=rand(number_of_obstacle,5)*A_ob+B_ob;
obstacle=obstacle';
            
obstacleR = 0.5;% ��ͻ�ж��õ��ϰ���뾶

global dt; 
dt = 0.1;% ʱ��[s]

% �������˶�ѧģ�Ͳ���
% ����ٶ�[m/s],�����ת�ٶ�[rad/s],���ٶ�[m/ss],��ת���ٶ�[rad/ss],�ٶȷֱ���[m/s],ת�ٷֱ���[rad/s]]
model = [1.0,toRadian(20.0),0.2,toRadian(50.0),0.01,toRadian(1)];

%����model���±�
MD_MAX_V    = 1;%   ����ٶ�m/s]
MD_MAX_W    = 2;%   �����ת�ٶ�[rad/s]
MD_ACC      = 3;%   ���ٶ�[m/ss]
MD_VW       = 4;%   ��ת���ٶ�[rad/ss]
MD_V_RESOLUTION  = 5;%  �ٶȷֱ���[m/s]
MD_W_RESOLUTION  = 6;%  ת�ٷֱ���[rad/s]]


% ���ۺ������� [heading,dist,velocity,predictDT]
% ����÷ֵı��ء�����÷ֵı��ء��ٶȵ÷ֵı��ء���ǰģ��켣��ʱ��
evalParam = [0.05, 0.2 ,0.1, 3.0];

area      =[-3 14 -3 14];% ģ������Χ [xmin xmax ymin ymax]

% ģ��ʵ��Ľ��
result.x=[];   %�ۻ��洢�߹��Ĺ켣���״ֵ̬ 
tic; % �����������ʱ�俪ʼ

writerObj=VideoWriter('./results/test.avi');  % ����һ����Ƶ�ļ������涯��
open(writerObj);                    % �򿪸���Ƶ�ļ�

%% Main loop   ѭ������ 5000�� ָ���ﵽĿ�ĵ� ���� 5000�����н���
for i = 1:5000  
    % DWA�������� ���ؿ����� u = [v(m/s),w(rad/s)] �� �켣
    [u,traj] = DynamicWindowApproach(x,model,goal,evalParam,obstacle,obstacleR);
    
    x = f(x,u);% �������ƶ�����һ��ʱ�̵�״̬�� ���ݵ�ǰ�ٶȺͽ��ٶ��Ƶ� ��һ�̵�λ�úͽǶ�
    obstacle=MoveObstacle(obstacle);
    % ��ʷ�켣�ı���
    result.x = [result.x; x'];  %���½�� ���е���ʽ ��ӵ�result.x
    
    % �Ƿ񵽴�Ŀ�ĵ�
    if norm(x(POSE_X:POSE_Y)-goal')<0.25   % norm��������������ϵ�������֮��ľ���
        disp('Arrive Goal!!');break;
    end
    
    %====Animation====
    hold off;               % �ر�ͼ�α��ֹ��ܡ� ��ͼ����ʱ��ȡ��ԭͼ����ʾ��
    ArrowLength = 0.5;      % ��ͷ����
    
    % ������
    % quiver(x,y,u,v) �� x �� y ��ÿ����ӦԪ�ض�����ָ�������괦����������Ϊ��ͷ
    quiver(x(POSE_X), x(POSE_Y), ArrowLength*cos(x(YAW_ANGLE)), ArrowLength*sin(x(YAW_ANGLE)), 'ok'); % ���ƻ����˵�ǰλ�õĺ����ͷ
    hold on;                                                     %����ͼ�α��ֹ��ܣ���ǰ�������ͼ�ζ������֣��Ӵ˻��Ƶ�ͼ�ζ�����������ͼ�εĻ����ϣ����Զ�����������ķ�Χ
    
    plot(result.x(:,POSE_X),result.x(:,POSE_Y),'-b');hold on;    % �����߹�������λ�� ������ʷ���ݵ� X��Y����
    plot(goal(1),goal(2),'*r');hold on;                          % ����Ŀ��λ��
    
    %plot(obstacle(:,1),obstacle(:,2),'*k');hold on;              % ���������ϰ���λ��
    DrawObstacle_plot(obstacle,obstacleR);
    
    % ̽���켣 ���������۵Ĺ켣
    if ~isempty(traj) %�켣�ǿ�
        for it=1:length(traj(:,1))/5    %�������й켣��  traj ÿ5������ ��ʾһ���켣��
            ind = 1+(it-1)*5; %�� it ���켣��Ӧ��traj�е��±� 
            plot(traj(ind,:),traj(ind+1,:),'-g');hold on;  %����һ���켣�ĵ㴮�����켣   traj(ind,:) ��ʾ��ind���켣������x����ֵ  traj(ind+1,:)��ʾ��ind���켣������y����ֵ
        end
    end
    
    axis(area); %����area���õ�ǰͼ�ε����귶Χ���ֱ�Ϊx�����С�����ֵ��y�����С���ֵ
    grid on;
    drawnow;  %ˢ����Ļ. ������ִ��ʱ�䳤����Ҫ����ִ��plotʱ��Matlab���򲻻����ϰ�ͼ�񻭵�figure�ϣ���ʱ��Ҫ��ʵʱ����ͼ���ÿһ���仯�������Ҫʹ�������䡣
    frame = getframe;            %// ��ͼ�������Ƶ�ļ���
    writeVideo(writerObj,frame); %// ��֡д����Ƶ
end

close(writerObj); %// �ر���Ƶ�ļ����

toc  %�����������ʱ��  ��ʽ��ʱ���ѹ� ** �롣





