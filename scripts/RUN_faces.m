
% 1. grab participant number ___________________________________________________

prompt = 'PARTICIPANT number (in raw number form, e.g. 1, 2,...,98): ';
sub = input(prompt);

prompt = ' RUN number (1, 2, or 3): ';
run = input(prompt);

prompt = 'BIOPAC (YES=1 NO=0) : ';
biopac = input(prompt);


% 2. counterbalance version ____________________________________________________
% random sequence
r_seq =  [1,3,2,3,3,1,2,4,4,2,3];
index= rem(sub,10)+1;
f = ['task-faces_counterbalance_ver-0' num2str(r_seq(index+1))];
faces(sub,f, run, biopac)

