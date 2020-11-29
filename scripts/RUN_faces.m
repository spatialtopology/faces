
% 1. grab participant number ___________________________________________________

<<<<<<< HEAD
prompt = 'PARTICIPANT number (in raw number form, e.g. 1, 2,...,98): ';
sub = input(prompt);

prompt = ' RUN number (1, 2, or 3): ';
run = input(prompt);

prompt = 'BIOPAC (YES=1 NO=0) : ';
biopac = input(prompt);
=======
prompt = 'subject number (in raw number form, e.g. 1, 2,...,98): ';
sub = input(prompt);

prompt = ' run number (in raw number form, i.e. 1, 2, or 3): ';
run = input(prompt);

>>>>>>> bf890abe8b508ad6b426fc767920929f29314468
% 2. counterbalance version ____________________________________________________
% random sequence
r_seq =  [1,3,2,3,3,1,2,4,4,2,3];
index= rem(sub,10)+1;
f = ['task-faces_counterbalance_ver-0' num2str(r_seq(index+1))];
<<<<<<< HEAD
faces(sub,f, run, biopac)
=======
faces(sub,f, run)



>>>>>>> bf890abe8b508ad6b426fc767920929f29314468
