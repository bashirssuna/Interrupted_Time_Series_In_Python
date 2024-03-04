
sort id
*data cleaning and sorting
gen gen newdate = date(date, "DMY")
ncode sex, generate(Sex)
encode visittype2, generate(Visittype)
encode febrile, generate(Febrile)
drop date sex visittype2 febrile 
recode age (min/2.999=1 "6mo-2years") (3/5.999=2 "3-5 years") (6/max=3 "6-12 years"), g(agecat)

*how many patients are in the cohort?
egen tag_id_all = tag(id)
egen total_participants_all = total(tag_id_all)

*Determine who tested positive for malaria
gen Malaria_positive = 1 if parasitedensity !=0
replace Malaria_positive =0 if Malaria_positive==.

*Determine the followup_time for every patient for every visit
sort id newdate
by id: gen followup_time = newdate - newdate[_n-1]
recode followup_time (.=0)

*generate followup episodes for patients with symptomatic_malaria 
gen symptomatic_malaria = ( Febrile==2& Malaria_positive==1)

*Calculate the total followup_time for symptomatic_malaria guys
egen symptomatic_followup_time = total(followup_time) if symptomatic_malaria == 1, missing

*Calculate the total followup_time for the non cases
egen noncases_followup_time = total(followup_time) if symptomatic_malaria == 0, missing

*How many patients have symptomatic_malaria?
egen tag_id = tag(id) if symptomatic_malaria==1
egen total_participants = total(tag_id)

*Lets separate year, month and year_month for seasonal incidence / prevalence
gen year = year( newdate )
gen month = month( newdate )
gen year_month = string(year) + "_" + string(month, "%02.0f")
encode year_month, g(y_m)

iri 2427 8659 219.01918 1055.5562, exact
