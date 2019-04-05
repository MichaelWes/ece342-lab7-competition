package definesPkg;
   // TODO: Determine the right width
   parameter IF_ID_WIDTH = 16 * 3;
   
   // TODO: Determine the right width
   parameter ID_EX_WIDTH = (16 * 6) + (2 * 3) + (2 * 1) + 16 + 16;
   
   //TODO: Determine the right width
   parameter EX_WB_WIDTH = (16 * 5);
	
	parameter BTB_num_rows = 1 << 5;
	
endpackage