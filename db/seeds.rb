la = Region.create(name:"Los Angeles", latitude: 34.052234, longitude: 118.243685)
tokyo = Region.create(name:"Tokyo", latitude: 34.052234, longitude: -118.243685)

la.remote_image_url = "http://www.elenavlasyuk.com/wp-content/uploads/los-angeles-la-usa-night-los-angeles-night-lights-cityscapes2.jpg"
la.save

tokyo.remote_image_url = "http://vacationadvice101.com/wp-content/uploads/2013/06/tokyo.jpg"
tokyo.save

u1 = User.create(
	email:"david@luxhaven.com", 
	firstname:"David", 
	lastname:"Kong", 
	admin:true, 
	password:"123", 
	password_confirmation: "123"
)



l1 = Listing.new(
	price_per_night: 43600,
	property_type: "house",
	title: "Trap spot",
	accomodates_from: 1,
	accomodates_to: 4,
	bedrooms: 2,
	baths: 1,
	washer: true,
	search_description: "Mad trap spot"
)

l1.user = u1

a1 = Address.new(
    street1: "4643 This Street",
    city: "Los Angeles",
    state: "CA",
    zip: "90024",
    neighborhood: "Westwood"
)

a1.region = la
l1.address = a1
a1.save
l1.save

i1 = l1.images.build
i1.remote_image_url = "http://www.worldpropertychannel.com/news-assets/denver-lofts-apartments-residential.jpg"
i1.save

l1.update_attribute :remote_search_image_url, "http://www.worldpropertychannel.com/news-assets/denver-lofts-apartments-residential.jpg"    

l2 = Listing.new(
	price_per_night: 90600,
	property_type: "apartment",
	title: "nice place",
	accomodates_from: 1,
	accomodates_to: 4,
	bedrooms: 1,
	baths: 1, 
	washer: true,
	search_description: "really nice place"
)

l2.user = u1

a2 = Address.new(
	street1: "1234 New Street",
	city: "Tokyo",
	neighborhood: "Akibahara"
)

a2.region = tokyo
l2.address = a2
a2.save
l2.save

i2 = l2.images.build
i2.remote_image_url = "http://www.viahouse.com/wp-content/uploads/2010/10/Simple-and-Minimalist-Apartment-Plans-in-Tokyo.jpg"
i2.save 

l2.update_attribute :remote_search_image_url, "http://www.viahouse.com/wp-content/uploads/2010/10/Simple-and-Minimalist-Apartment-Plans-in-Tokyo.jpg"

job1 = Job.create(
	city: "Los Angeles",
	active: true,
	title: "Software Engineer",
	description: 'Luxhaven is looking for a junior product manager who loves turning data - both qualitive anq quantitative - into actionable ways to drive growth. The ideal candidate is an engineer who is looking to transition from an engineering role into a product role with a marketing/business focus.'
)

job2 = Job.create(
	city: "Los Angeles",
	active: true,
	title: "Graphic Designer",
	description: "Working on graphical stuff"
)

qual1 = JobQualification.create(
	text: "Are really good software engineers"
)
job1.about_qualifications.push qual1

qual2 = JobQualification.create(
	text: "Get really excited about tough challenges"
)
job1.about_qualifications.push qual2

qual3 = JobQualification.create(
	text: "2+ years of engineering experience"
)
job1.skill_qualifications.push qual2

qual4 = JobQualification.create(
	text: "Develop and execute product strategy for business arm"
)
job1.responsibility_qualifications.push qual3