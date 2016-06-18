`ifndef CLASS_MONITOR_T
`define CLASS_MONITOR_T
`include "../../testbench/packet.sv"
`include "../../testbench/mac_interface.sv"

class monitor;

	integer rx_count;
	packet ethernet;
	virtual mac_interface mi;
	mailbox mon2sb;

  	function new(	input virtual mac_interface mif,
               		input mailbox mon2sb);
        	this.mi = mif;
        	rx_count = 0;
        	this.mon2sb = mon2sb;
		ethernet = new();
    	endfunction

    	// Task to read a single packet from receive interface and display  
  	task receive_packet;
        packet pkt;
		pkt = new ethernet;
		bit [63:0] data[];
		bit sop[],eop[],val[];
		
		 @(mi.pkt.cb)
		 		 //-------------SOP---------------
		 if(mi.pkt_rx_sop && mi.pkt_rx_val && !mi.pkt_rx_eop) begin
		    data[0] = mi.pkt_cb.pkt_rx_data;
			sop[0] =1;
			val[0] =1;
			eop[0] =0;
		 end	 
		 //-------------MOP---------------
         else if(!mi.pkt_rx_sop && mi.pkt_rx_val && !mi.pkt_rx_eop) begin	        
			data[data.size()] = mi.pkt_cb.pkt_rx_data;
			sop[data.size()] =0;
			val[data.size()] =1;
			eop[data.size()] =0;			 
			end
		 end
	
	     //-------------EOP---------------
	     else if(!mi.pkt_rx_sop && mi.pkt_rx_val && mi.pkt_rx_eop)begin
		 	data[data.size()] = mi.pkt_cb.pkt_rx_data;
			sop[data.size()] =0;
			val[data.size()] =1;
			eop[data.size()] =0;
		 end
		 

		 	pkt.dst_addr = data[0][64:16];
			pkt.src_addr [47:32] =data[0][15: 0];
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 //-------------SOP---------------
		 if(mi.pkt_rx_sop && mi.pkt_rx_val && !mi.pkt_rx_eop) begin
		    pkt.dst_addr = mi.pkt_cb.pkt_rx_data[63:16];
			pkt.src_addr [47:32] = mi.pkt_cb.pkt_rx_data[15: 0];
			data[0] = mi.pkt_cb.pkt_rx_data;
		 end
		 
		 //-------------MOP---------------
         else if(!mi.pkt_rx_sop && mi.pkt_rx_val && !mi.pkt_rx_eop) begin
	        
			data[data.size()] = mi.pkt_cb.pkt_rx_data;
			
		    if(data.size()==1) begin
			 pkt.src_addr   [31:0] = mi.pkt_cb.pkt_rx_data[63:32];
			 pkt.ether_type [15:0] = mi.pkt_cb.pkt_rx_data[31:16];
			 // assumes that pkt.payload.size is larger than 2
			 pkt.payload [0] = mi.pkt_cb.pkt_rx_data[15:8];
			 pkt.payload [1] = mi.pkt_cb.pkt_rx_data[7:0];
			 
			 else begin
			 pkt.payload [8*data.size()-14] = mi.pkt_cb.pkt_rx_data[63:56];
			 pkt.payload [8*data.size()-13] = mi.pkt_cb.pkt_rx_data[55:48];
			 pkt.payload [8*data.size()-12] = mi.pkt_cb.pkt_rx_data[47:40];
			 pkt.payload [8*data.size()-11] = mi.pkt_cb.pkt_rx_data[39:32];
			 pkt.payload [8*data.size()-10] = mi.pkt_cb.pkt_rx_data[31:24];
			 pkt.payload [8*data.size()- 9] = mi.pkt_cb.pkt_rx_data[23:16];
			 pkt.payload [8*data.size()- 8] = mi.pkt_cb.pkt_rx_data[15: 8];
			 pkt.payload [8*data.size()- 7] = mi.pkt_cb.pkt_rx_data[7 : 0];
			 end
			 
			end
		 end
	
	     //-------------EOP---------------
	     else if(!mi.pkt_rx_sop && mi.pkt_rx_val && mi.pkt_rx_eop)begin
		 
		 end
	endtask
    
endclass

`endif


