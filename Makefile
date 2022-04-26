ifndef submission
$(error submission is undefined)
endif

failsafe:
	mkdir scoring
	echo Creating failsafe json, this will be overwritten by a successful submission...
	echo '{"Sadie_Runtime": -1, "Sadie_Params": -1, "Sadie_Raw_Score": -1, "Sadie_Adj_Score": -100, "Isabella_Runtime": -1, "Isabella_Params": -1, "Isabella_Raw_Score": -1, "Isabella_Adj_Score": -100, "Chester_Runtime": -1, "Chester_Params": -1, "Chester_Raw_Score": -1, "Chester_Adj_Score": -100, "Final_Score": -100}' >> scoring/final_results.json

build:
ifneq (,$(wildcard $(submission)/main.py))
	$(error ERROR: User submission contains a file named main.py. Please rename or remove any file named main.py in your submission, otherwise it will be overwritten.)
endif
	rm -Rf package
	mkdir package
	mkdir package/predictions
	mkdir package/datasets
	rsync -ar --exclude='**/test_y.npy' datasets/* package/datasets/
	cp -R $(submission)/* package
	cp -R evaluation/main.py package/main.py

run:
	cd package; python3 main.py

score:
	mkdir scoring/labels
	mkdir scoring/predictions
	rsync -avr --exclude='**/*x.npy' --exclude='**/train*.npy' --exclude='**/valid*.npy'   --include='**/test_y.npy' datasets/* scoring/labels/
	cp -R package/predictions scoring
	cp evaluation/score.py scoring/score.py
	cd scoring; python3 score.py

clean:
	rm -Rf scoring
	rm -Rf package

zip:
	cd $(submission);  zip -r ../submission.zip *

all: clean failsafe build run score
