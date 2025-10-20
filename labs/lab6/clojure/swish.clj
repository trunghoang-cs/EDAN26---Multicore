
(def start-balance 1000)    	; initial balance in each account. 
(def num-accounts 4)			; the number of accounts. 
(def num-transactions 10)		; the number of random transfers to perform across all thread. 
(def num-threads 3)				; use 1 thread (change to > 1 for concurrent testing)
(def extra-processing 1000)		; artificial busy-work inside each transaction ???
(def max-amount	100)			; the the maximum random amount to transfer in one swish.

(defrecord account [balance])	; create a class, with the balance attribute inside.  

(def accounts (vec (for [i (range num-accounts)] (ref (->account start-balance)))))  
				; create the instances of the account object. 
				; the number of instances is defined by the num-accounts
(defn do-extra-processing [n] 	; the implementation of busy wait, 
	(if (>= n 1)				; count down from n to 0, and do nothing. created for delay the process. 
		(recur (- n 1))))
		
(defn swish [from to amount]	;
	(dosync 
		(do-extra-processing extra-processing)
		(ref-set (accounts from) (update @(accounts from) :balance - amount)) ; dereference the ref at index from to get the accoutn record
		(ref-set (accounts to) (update @(accounts to) :balance + amount))))	  ; deereference the ref at to index to get and update the ref to the new account record. 

(defn work [t]  	; the number of transactions this thread should perform. 
	(if (>= t 1)	; the condition if t >= 1 
		(do			; then loop
			(swish (rand-int num-accounts) (rand-int num-accounts) (rand-int max-amount)) ; rand-int returns a random integer from 0 to n-1. 
			(recur (- t 1)))))		; way to do tail-recursive without making the stack grows. 
									; recur reuses the current frame, rebinds the function parameter to new-value and restarts. 

(defn read-balance [a] (:balance a)) ; access the record a and return the field a. 

(defn sum [hd] (if (empty? hd) 0 (+ (read-balance (first hd)) (sum (rest hd)))))
	; the recursive sum function
	; hd - a sequence/list of accoutn record
	; call the read-balance on the first account instance, recursive call sum on the rest.
	; when there is an empty sequence, return 0, complete the calculation. 
(defn check [] (= (* num-accounts start-balance) (sum (map deref accounts))))
	; return true when the from the right half and the left half is the same. 
	; deref or @ reads the current value inside of the ref.
	; for this example return the account record, containing the balance field. 
	; map applies the redef functions on each ref, return a sequence of account records. 
(defn make-transactions [] (work (/ num-transactions num-threads)))
	; this function take no arguments
	; divide the num-transactions even between each threads. 
(defn main []

	(println "swish with clojure software transactional memory")
	(println "accounts: " num-accounts)
	(println "transactions: " num-transactions)
	(println "threads: " num-threads)

	(let [threads (repeatedly num-threads #(Thread. make-transactions))] 
		(run! #(.start %) threads)	; call run on each thread	
		(run! #(.join %) threads))	; waith for thread to join and end	
		; create num-threads Thread objects 
		; each thread will call the make-transactions functions when created. 
	(if (check) (println "PASS") (println "FAIL")))


(main)
(println (map deref accounts))
	(if (check) (println "PASS") (println "FAIL"))
