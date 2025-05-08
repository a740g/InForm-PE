// On page load this script scans all page links.
// These are tested against the current page URL
// On finding a match the corresponding class is set to
// 'current' the following css is used:
// 
//   #sidenav a.active {
//    background-color: #ccc; /* Add  color to the "active/current" link */
//    color: white;
//  }

//  /* Current page selected link */
//  /* Target specific menu. Note current is set by js*/

//  #sidenav .current {
//    background-color: #ccc;
//  }


 function highlightCurrent() {
         const curPage = document.URL;
         const links = document.getElementsByTagName('a');

//console.log( curPage);

         for (let link of links) {

console.log(curPage + '   ' + link.href );

           if (link.href === curPage) {
             link.classList.add("current");
           }
         }
       }


       document.onreadystatechange = () => {
         if (document.readyState === 'complete') {
           highlightCurrent()
         }
       };
