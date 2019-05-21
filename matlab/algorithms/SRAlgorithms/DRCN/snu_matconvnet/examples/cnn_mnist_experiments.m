%% Experiment with the cnn_mnist_fc_bnorm

pbObj = [] ; % pbNotify('accessToken');
% usage : pbNotify('accessToken'); from https://www.pushbullet.com/account

try
[net_bn, info_bn] = cnn_mnist(...
  'expDir', 'data/mnist-bnorm', 'useBnorm', true, 'gpus', [], 'pushbullet', pbObj);

[net_fc, info_fc] = cnn_mnist(...
  'expDir', 'data/mnist-baseline', 'useBnorm', false, 'gpus', [], 'pushbullet', pbObj);
catch
    if ~isempty(pbObj)
        pbObj.notify('Error happened during execution');
    else
        fprintf('Error happened during execution');
    end
end

%%
figure(1) ; clf ;
subplot(1,2,1) ;
semilogy(info_fc.val.objective, 'k') ; hold on ;
semilogy(info_bn.val.objective, 'b') ;
xlabel('Training samples [x10^3]'); ylabel('energy') ;
grid on ;
h=legend('BSLN', 'BNORM') ;
set(h,'color','none');
title('objective') ;
subplot(1,2,2) ;
plot(info_fc.val.error(1,:), 'k') ; hold on ; % first row for top1e
plot(info_fc.val.error(2,:), 'k--') ; % second row for top5e
plot(info_bn.val.error(1,:), 'b') ;
plot(info_bn.val.error(2,:), 'b--') ;
h=legend('BSLN-val','BSLN-val-5','BNORM-val','BNORM-val-5') ;
grid on ;
xlabel('Training samples [x10^3]'); ylabel('error') ;
set(h,'color','none') ;
title('error') ;
drawnow ;