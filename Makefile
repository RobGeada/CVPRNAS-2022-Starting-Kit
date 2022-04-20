ifndef submission
$(error submission is undefined)
endif

build:
	rm -Rf package
	mkdir package
	mkdir package/predictions
	mkdir package/datasets
	rsync -ar --exclude='**/test_y.npy' datasets/* package/datasets/
	if [ -f "$(submission)/main.py" ]; then
	    $(error ERROR: User submission contains a file named main.py. Please rename or remove any file named main.py in your submission, otherwise it will be overwritten.)
	fi
	cp -R $(submission)/* package
	cp -R evaluation/main.py package/main.py

run:
	cd package; python3 main.py

score:
	rm -Rf scoring
	mkdir scoring
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

all: clean build run score
