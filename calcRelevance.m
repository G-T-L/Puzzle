    %
    % Description :
    % v1,v2 are supposed to be scaled value
    % given two (list of) Property Value and calc the relevanceValue
    % Matrix input are supported
    %
    % could be modified to achieve better performance
    function relevanceValue = calcRelevance(v1,v2,ismatchedMatrix,mode)
    if nargin<4
        mode='balance';
    elseif nargin<3
        ismatchedMatrix=[];
    end

    if ~ismember(mode,{'balance','edgeDominant'})
        disp('invalid mode option, balance mode was used automatically');
        mode='balance';
    end

    switch mode
        case 'balance'
    %         relevanceValueArray=1-(v1-v2).^2;

            relevanceValueArray=1-(v1-v2).^2./((v1+0.0001).^2+v2.^2); %in case v1==v1==0
            relevanceValue=mean(mean(relevanceValueArray));

        case 'edgeDominant'
            relevanceValueArray=1-(v1-v2).^2;

            if ~isempty(ismatchedMatrix)
                ismatchedMatrix=ismatchedMatrix(:,ones(size(v1,2),1));
                relevanceValueArray=relevanceValueArray.*ismatchedMatrix;
            else
                disp('waring: ismatchedMatrix is empty edge detection enhance aborted');
            end
            relevanceValue=mean(mean(relevanceValueArray));

        otherwise

    end

    end

%         archived code:
%         relevanceValueArray=1-(v1-v2).^2./((v1+0.0001).^2+v2.^2); %in case v1==v1==0
%         relevanceValue=mean(mean(relevanceValueArray));
%
%         use covariance to evaluate
%         but when v2==0 this failed
%         relevanceValueArray = ( v1-mean(v1)).*(v2-mean(v2));
%         relevanceValue=mean(mean(relevanceValueArray));
%

